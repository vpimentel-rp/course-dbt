**Part 1. Models**

*1. What is our user repeat rate?* 

Answer: 79.84% repeat rate

```sql

WITH orders_cohort
     AS (SELECT user_id,
                Count(DISTINCT( order_id )) AS user_orders
         FROM   dev_db.dbt_vpimentelravenpackcom.stg_orders
         GROUP  BY 1),
     users_bucket
     AS (SELECT user_id,
                ( user_orders = 1 ) :: INT  AS has_one_purchase,
                ( user_orders = 2 ) :: INT  AS has_two_purchases,
                ( user_orders = 3 ) :: INT  AS has_three_purchases,
                ( user_orders >= 2 ) :: INT AS has_two_plus_purchases
         FROM   orders_cohort)
SELECT SUM(has_one_purchase)                          AS one_purchase,
       SUM(has_two_purchases)                         AS two_purchases,
       SUM(has_three_purchases)                       AS three_purchases,
       SUM(has_two_plus_purchases)                    AS two_plus_purchases,
       Count(DISTINCT user_id)                        AS num_users_w_purchase,
       Div0(two_plus_purchases, num_users_w_purchase) AS repeat_rate
FROM   users_bucket 

```

*2. What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question?*

**Good indicators of a user who will likely purchase again:**

- *Total Number of Orders:* Users with a higher total number of orders are more likely to make future purchases, indicating their loyalty to the brand.

- *Distribution of Event Types:* Analyzing how users interact with the platform can be insightful. Users who frequently add items to their cart and proceed to checkout are more likely to become repeat customers.

**Indicators of users likely NOT to purchase again:**

- *Promo Code Usage:* Users who frequently use promotional codes may be motivated primarily by discounts. This behavior may suggest a lower likelihood of making repeat purchases at regular prices.

- *Lower Order Total:* Customers placing smaller orders might be trying the brand for the first time, and they may not have established a strong connection with the brand, making them less likely to return.

**Additional data features to consider:**

- *Return Rate:* It can be valuable to collect data on the rate of product returns. Customers who rarely return items are more likely to be satisfied with their purchases and may become loyal customers.

- *Subscription Model Adoption:* If your business offers a subscription model, users who opt for subscriptions are strong candidates for repeat purchases. They have committed to receiving products regularly, indicating a higher level of loyalty.

In summary, understanding user behavior and predicting their likelihood to make future purchases is essential for effective marketing and customer retention. Analyzing these indicators, along with additional data like return rates and subscription adoption, can provide a more comprehensive view of customer behavior and inform strategies to encourage repeat purchases.

**Part 2. Tests**

1. **What assumptions are you making about each model? (i.e. why are you adding each test?)**

    - *valid_delivery_date.sql*: This test assumes that there are no instances of `delivered_at` being earlier than `created_at` because that would mean that the order was delivered before it was placed.

    - *datediff test*: Another test calculates the difference between the estimated delivery date and actual delivery date on `stg_orders` and checks if there's a difference of greater than one week. If this test failed, it could indicate that an order was lost during shipping, warranting further investigation by the customer service team.

    - Generic tests: For columns like `id` (e.g., `user_id`, `order_id`), I used the `unique` and `not_null` tests because these values should always be present in each table and should also be unique. Additionally, I used generic relationship tests to ensure correct relations between the same column in different tables (e.g., `order_id` in `stg_orders` and `stg_events`).

    - For intermediate and fact models, I frequently used the `positive_values` test for values that should never be less than zero, such as `page_views`, `checkouts`, `total_views`, `total_orders`, and `conversion_rate`.

2. **Did you find any “bad” data as you added and ran tests on your models? How did you go about either cleaning the data in the dbt model or adjusting your assumptions/tests?**

    - I encountered an error for the `not_null` test on the `tracking_id` column in the `stg_orders` table. Further investigation revealed that orders still being prepared do not yet have a tracking number, explaining why some orders had a null value for `tracking_id`.

    - I assumed that `order_id` and `product_id` would be unique in `stg_events`, but this assumption failed due to different site events (e.g., checkout, package_shipped) for the same order sharing the same `order_id` and `product_id`.

    - There were 9 entries in `stg_orders` with the same `tracking_id`, which I assumed to be unique. However, this may be due to multiple boxes for one shipment, all sharing the same `tracking_id`.

    - A relationships test between `address_id` from `stg_addresses` to `stg_users` produced 61 errors. This likely indicates that `stg_users` consists of users who have registered their information on the site, while `stg_addresses` encompasses everyone who has ordered, registered or not, leading to the disparity.

    - Similarly, I assumed `address_id` would be unique in `stg_users`, but this test also produced an error, likely indicating that multiple users are ordering from the same address.

3. **Your stakeholders at Greenery want to understand the state of the data each day. Explain how you would ensure these tests are passing regularly and how you would alert stakeholders about bad data getting through.**

    - To ensure consistent testing, I would schedule a dbt test to run after each scheduled dbt process, aiming for daily or more frequent tests.

    - To alert stakeholders to potential data quality issues, I would establish an alerting system integrated with communication platforms like Slack. Whenever a test fails, an automated notification would be sent to relevant stakeholders, ensuring immediate awareness of any issues. The analytics engineering team could then promptly investigate and address data quality concerns.



**Part 3. dbt Snapshots**

*1. Which products had their inventory change from week 1 to week 2?*

Answer: Pothos, Philodendron, Monstera and String of Pearls.
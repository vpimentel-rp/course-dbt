**Part 1. dbt Snapshots**

*1. Which products had their inventory change from week 3 to week 4?*

```sql
select *
from dev_db.dbt_vpimentelravenpackcom.products_snapshot
where product_id in (
    select product_id
    from dev_db.dbt_vpimentelravenpackcom.products_snapshot
    group by 1
    having count(1) > 1
    )
order by dbt_valid_from;

select * from dev_db.dbt_vpimentelravenpackcom.products_snapshot
where date_trunc(week, dbt_valid_to) = date_trunc(week, current_date);
```

* Bamboo: from 44 to 23
* Monstera: from 50 to 31
* Philodendron: from 15 to 30
* Pothos: from 0 to 20
* String of Pearls: from 0 to 10
* ZZ Plant: from 53 to 41

*2. Now that we have 3 weeks of snapshot data, can you use the inventory changes to determine which products had the most fluctuations in inventory? Did we have any items go out of stock in the last 3 weeks?*

The products that had the most fluctuations in inventory were, with 4 fluctuations: Monstera, Philodendron, Pothos and String of Pearls; and with 3 fluctuations: Bamboo and ZZ Plant.

In addition, two products briefly went out of stock in the last 3 weeks: Pothos and String of Pearls.

**Part 2. Modeling challenge**

*1. How are our users moving through the product funnel?*

```sql

WITH sessions_with_event_type AS
(
       SELECT *
       FROM   dev_db.dbt_vpimentelravenpackcom.int_sessions_with_event_type
), 
final AS(
       SELECT SUM(add_to_cart_sessions) AS distinct_add_to_cart_sessions ,
              SUM(page_view_sessions) AS distinct_page_view_sessions ,
              SUM(checkout_sessions) AS distinct_checkout_sessions ,
              SUM(add_to_cart_sessions)/SUM(page_view_sessions) AS add_to_cart_rate ,
              SUM(checkout_sessions)/SUM(add_to_cart_sessions) AS cart_to_checkout_rate ,
              SUM(checkout_sessions)/SUM(page_view_sessions) AS overall_conversion_rate
       FROM   sessions_with_event_type 
)
SELECT *
FROM   final

```

* Distinct Add-to-Cart Sessions: 467 sessions involved adding items to the cart.

* Distinct Page View Sessions: 578 sessions included viewing pages on the website.

* Distinct Checkout Sessions: 361 sessions proceeded to the checkout process.

* Add-to-Cart Rate: About 80.8% of page view sessions resulted in users adding items to the cart.

* Cart-to-Checkout Rate: Approximately 77.3% of users who added items to their carts proceeded to the checkout process.

* Overall Conversion Rate: The overall conversion rate from page views to checkout sessions was approximately 62.5%.


*2. Which steps in the funnel have largest drop off points?*

The most significant drop-off points within the funnel occur when customers transition from adding a product to their cart to successfully completing the checkout process, with a conversion rate of 77.3%. This is closely followed by the conversion rate of 80.8% when customers move from viewing a product to adding it to their cart.

*3. Use an exposure on your product analytics model to represent that this is being used in downstream BI tools.*

I added the exposure in models/marts/product as _product_exposures.yml.
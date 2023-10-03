**Part 1: Create new models to answer the first two questions**

*1. What is our overall conversion rate?* 62.45%

```sql

WITH events_distinct_session_type
     AS (SELECT DISTINCT( session_id ),
                        CASE
                          WHEN checkouts > 0 THEN 1
                          ELSE 0
                        END AS checkouts,
                        CASE
                          WHEN page_views > 0 THEN 1
                          ELSE 0
                        END AS page_views
         FROM   dev_db.dbt_vpimentelravenpackcom.int_session_events_agg
         GROUP  BY session_id,
                   checkouts,
                   page_views),
     agg
     AS (SELECT Sum(events_distinct_session_type.page_views) AS
                distinct_view_sessions,
                Sum(events_distinct_session_type.checkouts)  AS
                   distinct_checkout_sessions
         FROM   events_distinct_session_type),
     final
     AS (SELECT distinct_view_sessions,
                distinct_checkout_sessions,
                ( distinct_checkout_sessions / distinct_view_sessions ) AS
                overall_conversion_rate
         FROM   agg)
SELECT *
FROM   final; 

```

*2. What is our conversion rate by product?*

|NAME               |DISTINCT_PAGE_VIEW_SESSIONS|DISTINCT_CHECKOUT_SESSIONS|CONVERSION_RATE|
|-------------------|---------------------------|--------------------------|---------------|
|String of pearls   |64                         |39                        |0.609375       |
|Arrow Head         |63                         |35                        |0.555556       |
|Pilea Peperomioides|59                         |28                        |0.474576       |
|Philodendron       |62                         |30                        |0.483871       |
|Money Tree         |56                         |26                        |0.464286       |
|Aloe Vera          |65                         |32                        |0.492308       |
|Angel Wings Begonia|61                         |24                        |0.393443       |
|Birds Nest Fern    |78                         |33                        |0.423077       |
|Boston Fern        |63                         |26                        |0.412698       |
|Pink Anthurium     |74                         |31                        |0.418919       |
|Cactus             |55                         |30                        |0.545455       |
|Majesty Palm       |67                         |33                        |0.492537       |
|Snake Plant        |73                         |29                        |0.397260       |
|Ponytail Palm      |70                         |28                        |0.400000       |
|Alocasia Polly     |51                         |21                        |0.411765       |
|Pothos             |61                         |21                        |0.344262       |
|ZZ Plant           |63                         |34                        |0.539683       |
|Dragon Tree        |62                         |29                        |0.467742       |
|Peace Lily         |66                         |27                        |0.409091       |
|Ficus              |68                         |29                        |0.426471       |
|Bamboo             |67                         |36                        |0.537313       |
|Devil's Ivy        |45                         |22                        |0.488889       |
|Bird of Paradise   |60                         |27                        |0.450000       |
|Spider Plant       |59                         |28                        |0.474576       |
|Jade Plant         |46                         |22                        |0.478261       |
|Calathea Makoyana  |53                         |27                        |0.509434       |
|Fiddle Leaf Fig    |56                         |28                        |0.500000       |
|Rubber Plant       |54                         |28                        |0.518519       |
|Monstera           |49                         |25                        |0.510204       |
|Orchid             |75                         |34                        |0.453333       |


```sql

WITH unique_sessions_per_product
     AS (SELECT *
         FROM
     dev_db.dbt_vpimentelravenpackcom.int_unique_session_type_per_product),
     final
     AS (SELECT NAME,
                distinct_page_view_sessions,
                distinct_checkout_sessions,
                distinct_checkout_sessions / distinct_page_view_sessions AS
                   conversion_rate
         FROM   unique_sessions_per_product)
SELECT *
FROM   final 

```

*3. Why might certain products be converting at higher/lower rates than others?*

The pricing factor plays a crucial role in influencing a customer's decision to make a purchase. For instance, products with higher price tags tend to experience lower conversion rates, as there are typically fewer potential buyers willing and able to invest in a more expensive item compared to a more affordable alternative. Likewise, products available at various competing retailers may also exhibit lower conversion rates, as customers often shop around to secure the best possible price for a specific item. Furthermore, in cases where a website features a review system, negative product reviews are likely to contribute to a decreased conversion rate.


**Part 2: Create a macro to simplify part of a model(s)**

I've developed and documented a macro designed to consolidate event types per session. This macro streamlines the recurring 'case when' statement that I had previously employed in the context of int_session_events_agg.


**Part 3: Add a post hook to your project to apply grants to the role “reporting”.**

Done

**Part 4: Install a package (i.e. dbt-utils, dbt-expectations) and apply one or more of the macros to your project**

I incorporated dbt-utils and dbt-expectations into my project, leveraging multiple macros for various purposes. 

**Part 5: Show (using dbt docs and the model DAGs) how you have simplified or improved a DAG using macros and/or dbt packages.**

I enhanced my DAG by harnessing macros from packages like dbt_utils and dbt_expectations to validate accepted ranges and data types within both my intermediate and fact models. Furthermore, I introduced a custom macro for consolidating event types per session, streamlining the repetitive 'case when' statement that was previously utilized in int_session_events_agg.


**Part 6: dbt Snapshots**

*1. Which products had their inventory change from week 2 to week 3?*

* Pothos decreased from 20 to 0
* Philodendron decreased from 25 to 15
* Bamboo decreased from 56 to 44
* ZZ Plant decreased from 89 to 53
* Monstera decreased from 64 to 50
* String of Pearls decreased from 10 to 0
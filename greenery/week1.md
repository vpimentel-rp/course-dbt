1. How many users do we have?
Answer: 130 users

```sql
select 
    count(distinct user_id) 
from 
    dev_db.dbt_vpimentelravenpackcom.stg_users;
```

2. On average, how many orders do we receive per hour?
Answer: 7.52 orders per hour

```sql
with grouped_orders as (
    select
        count(distinct order_id) as order_hour,
        date_trunc('hour', created_at)
    from
        dev_db.dbt_vpimentelravenpackcom.stg_orders
    group by 2
)
select
    round(avg(order_hour), 2)
from
    grouped_orders
```

3. On average, how long does an order take from being placed to being delivered?
Answer: 3.89 days

```sql
select 
    avg(datediff(day, created_at, delivered_at)) 
from 
    dev_db.dbt_vpimentelravenpackcom.stg_orders;
```

4. How many users have only made one purchase? Two purchases? Three+ purchases?
Answer: 1 purchase: 25 users, 2 purchases: 28 users, 3+ purchases: 71 users

```sql
with order_count as (
    select 
        user_id,
        count(order_id) as num_orders
    from 
        dev_db.dbt_vpimentelravenpackcom.stg_orders
    group by user_id
)
select 
    num_orders, 
    count(user_id)
from order_count 
group by num_orders 
order by num_orders asc;
```

5. On average, how many unique sessions do we have per hour?
Answer: 16.33

```sql
with unique_sessions as (
    select 
        date_trunc(hour, created_at) as hour_created, 
        count(distinct session_id) as unique_session_count
    from 
        dev_db.dbt_vpimentelravenpackcom.stg_events 
    group by hour_created
)
select 
    avg(unique_session_count) from unique_sessions;
```
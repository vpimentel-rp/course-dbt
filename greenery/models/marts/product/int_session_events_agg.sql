{{ config( MATERIALIZED = 'table' ) }} WITH final AS
(
         SELECT   user_id ,
                  session_id {{ agg_event_types ('stg_events', 'event_type') }} ,
                  /*
                    sum(case when event_type = 'page_view' then 1 else 0 end) as page_views,
                    sum(case when event_type = 'add_to_cart' then 1 else 0 end) as add_to_carts,
                    sum(case when event_type = 'checkout' then 1 else 0 end) as checkouts,
                    sum(case when event_type = 'package_shipped' then 1 else 0 end) as package_shippeds,
                  */
                  MIN(created_at) AS first_session_event_utc ,
                  MAX(created_at) AS last_session_event_utc
         FROM     {{ ref('stg_events')}}         GROUP BY user_id,
                  session_id )
SELECT *
FROM   final
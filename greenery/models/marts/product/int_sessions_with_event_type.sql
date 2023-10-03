{{ config( MATERIALIZED = 'table' ) }} WITH final AS
(
       SELECT session_id ,
              CASE
                     WHEN page_views > 0 THEN 1
                     ELSE 0
              END AS page_view_sessions ,
              CASE
                     WHEN add_to_carts > 0 THEN 1
                     ELSE 0
              END AS add_to_cart_sessions ,
              CASE
                     WHEN checkouts > 0 THEN 1
                     ELSE 0
              END AS checkout_sessions
       FROM   {{ ref('int_session_events_agg') }} )
SELECT *
FROM   final
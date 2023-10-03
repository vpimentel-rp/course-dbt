{{ config( MATERIALIZED = 'table' ) }} WITH unique_sessions_per_product AS
(
       SELECT *
       FROM   {{ ref('int_unique_session_type_per_product') }} ) , final AS
(
       SELECT name ,
              distinct_page_view_sessions ,
              distinct_add_to_cart_sessions ,
              distinct_checkout_sessions ,
              distinct_add_to_cart_sessions / distinct_page_view_sessions   AS add_to_cart_rate ,
              distinct_checkout_sessions    / distinct_add_to_cart_sessions AS cart_to_checkout_rate ,
              distinct_checkout_sessions    / distinct_page_view_sessions   AS overall_conversion_rate
       FROM   unique_sessions_per_product )
SELECT *
FROM   final
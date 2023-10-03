{{ config( MATERIALIZED = 'table' ) }} WITH sessions_with_event_type AS
(
       SELECT *
       FROM   {{ ref('int_sessions_with_event_type') }} ) , final AS
(
       SELECT SUM(page_view_sessions)                          AS distinct_page_view_sessions ,
              SUM(checkout_sessions)                           AS distinct_checkout_sessions ,
              SUM(checkout_sessions) / SUM(page_view_sessions) AS overall_conversion_rate
       FROM   sessions_with_event_type )
SELECT *
FROM   final
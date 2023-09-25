{{

    config(
        MATERIALIZED = 'table'
    )
}}

with final as (
    SELECT
        user_id, 
        session_id,
        sum(case when event_type = 'page_view' then 1 else 0 end) as page_views,
        sum(case when event_type = 'add_to_cart' then 1 else 0 end) as add_to_carts,
        sum(case when event_type = 'checkout' then 1 else 0 end) as checkouts,
        sum(case when event_type = 'package_shipped' then 1 else 0 end) as packages_shipped,
        min(created_at) as first_session_event_utc,
        max(created_at) as last_session_event_utc
    from {{ ref('stg_events')}}
    group by user_id, session_id    
)

select * from final
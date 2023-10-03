WITH events AS
(
       SELECT *
       FROM   {{ref ('stg_events') }} ) , order_items AS
(
       SELECT *
       FROM   {{ref ('stg_order_items') }} ) , products AS
(
       SELECT *
       FROM   {{ref ('stg_products') }} ) , views AS
(
         SELECT   product_id ,
                  COUNT(DISTINCT session_id) AS distinct_page_view_sessions
         FROM     events
         WHERE    event_type = 'page_view'
         GROUP BY product_id ) , carts AS
(
         SELECT   product_id ,
                  COUNT(DISTINCT session_id) AS distinct_add_to_cart_sessions
         FROM     events
         WHERE    event_type = 'add_to_cart'
         GROUP BY product_id ) , orders AS
(
          SELECT    order_items.product_id ,
                    COUNT(DISTINCT events.session_id) AS distinct_checkout_sessions
          FROM      events
          LEFT JOIN order_items
          ON        events.order_id = order_items.order_id
          WHERE     events.order_id IS NOT NULL
          GROUP BY  order_items.product_id ) , final AS
(
       SELECT products.name ,
              views.product_id ,
              views.distinct_page_view_sessions ,
              carts.distinct_add_to_cart_sessions ,
              orders.distinct_checkout_sessions
       FROM   views
       JOIN   orders    ON     views.product_id = orders.product_id
       JOIN   products  ON     products.product_id = orders.product_id
       JOIN   carts     ON     carts.product_id = orders.product_id )
SELECT *
FROM   final
with product_daily_performance as (
    select * from {{ref('int_product__daily_site_performance')}}
)

, order_daily_performance as (
    select * from {{ref('int_product__daily_order_performance')}}
)

, products as (
    select * from {{ref('d_products')}}
)

select
    coalesce(odp.dt, pdp.dt) as dt
    , coalesce(odp.product_uuid, pdp.product_uuid) as product_uuid
    , p.product_name
    , coalesce(pdp.n_page_views, 0) as product_page_views
    , coalesce(pdp.n_add_to_carts, 0) as product_add_to_carts
    , coalesce(odp.n_orders, 0) as n_orders
    , coalesce(odp.n_items, 0) as n_items
    , coalesce(odp.revenue_usd, 0) as revenue_usd
    , product_page_views / n_orders as page_views_per_order
    , product_add_to_carts - n_orders as abandoned_carts
    , coalesce(pdp.n_page_view_sessions,0) as product_page_view_sessions
    , coalesce(pdp.n_add_to_cart_sessions,0) as product_add_to_cart_sessions
    , coalesce(pdp.n_checkout_sessions,0) as product_checkout_sessions
    , 1-div0(product_add_to_cart_sessions::float, product_page_view_sessions) as add_to_cart_dropoff
    , 1-div0(product_checkout_sessions::float, product_add_to_cart_sessions) as checkout_dropoff
from order_daily_performance odp
    full join product_daily_performance pdp
        on odp.product_uuid = pdp.product_uuid
        and odp.dt = pdp.dt
    left join products p on coalesce(odp.product_uuid, pdp.product_uuid) = p.product_uuid
order by 1,2
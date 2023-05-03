with product_daily_performance as (
    select * from {{ref('int_product__daily_site_performance')}}
)

, products as (
    select * from {{ref('d_products')}}
)

select
    date_trunc(week, pdp.dt) as wk
    , pdp.product_uuid as product_uuid
    , p.product_name
    , sum(pdp.n_page_view_sessions) as product_page_view_sessions
    , sum(pdp.n_add_to_cart_sessions) as product_add_to_cart_sessions
    , sum(pdp.n_checkout_sessions) as product_checkout_sessions
    , 1-div0(product_add_to_cart_sessions::float, product_page_view_sessions) as add_to_cart_dropoff
    , 1-div0(product_checkout_sessions::float, product_add_to_cart_sessions) as checkout_dropoff
from product_daily_performance pdp
    left join products p on pdp.product_uuid = p.product_uuid
group by 1,2,3
order by 1,2
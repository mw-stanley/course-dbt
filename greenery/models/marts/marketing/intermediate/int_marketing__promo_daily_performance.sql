with orders as (
    select * from {{ref('f_orders')}}
)

select
    order_datetime::date as dt
    , promo_name
    , count(distinct order_uuid) as n_orders
    , sum(promo_discount_usd) as total_discount_usd
    , sum(order_total_usd) as total_revenue_usd
    , count(distinct user_uuid) as n_users
from orders

where promo_name is not null

group by 1,2
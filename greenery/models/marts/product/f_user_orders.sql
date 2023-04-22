with usrs as (
    select * from {{ref('d_users')}}
)

, orders as (
    select * from {{ref('f_orders')}}
)

SELECT
    u.user_uuid
    , u.country
    , count(distinct o.order_uuid) as n_orders
    , min(o.order_datetime) as first_order_at
    , max(o.order_datetime) as last_order_at
    , sum(o.order_total_usd) as total_spend_usd
    , sum(case when o.promo_name is not null then 1 else 0 end) as promos_used
    , sum(o.promo_discount_usd) as total_discount_usd
    , avg(o.days_in_transit) as average_days_in_transit
    , max(o.days_in_transit) as max_days_in_transit
    , avg(o.delivery_estimate_error_hours) as average_delivery_estimate_error_hours
    , max(o.delivery_estimate_error_hours) as max_delivery_estimate_error_hours

from usrs u
    inner join orders o
        on u.user_uuid = o.user_uuid

group by 1,2
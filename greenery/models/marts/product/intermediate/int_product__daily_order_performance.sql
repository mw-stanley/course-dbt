with orders as (
    select * from {{ref('f_orders')}}
)

, order_items as (
    select * from {{ref('f_order_items')}}
)

, products as (
    select * from {{ref('d_products')}}
)

select
i.product_uuid
, o.order_datetime::date as dt
, count(distinct o.order_uuid) as n_orders
, sum(i.quantity_purchased) as n_items
, sum(i.quantity_purchased * p.price_usd) as revenue_usd
from orders o
inner join order_items i
    on o.order_uuid = i.order_uuid
inner join products p
    on i.product_uuid = p.product_uuid
group by 1,2
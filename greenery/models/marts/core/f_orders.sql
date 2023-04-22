with orders as (
    select * from {{ ref('stg_postgres__orders')}}
)

, addresses as (
    select * from {{ ref('stg_postgres__addresses')}}
)

, promos as (
    select * from {{ ref('stg_postgres__promos')}}
)

select
    o.order_uuid
    , o.created_at as order_datetime
    
    , o.status
    , o.user_uuid
        
    , o.order_cost_usd
    , o.shipping_cost_usd
    , o.order_total_usd

    , o.promo_name
    , p.discount_usd as promo_discount_usd
    
    , estimated_delivery_at
    , delivered_at
    , datediff('days', created_at, delivered_at) as days_in_transit
    , datediff('hour', estimated_delivery_at, delivered_at) as delivery_estimate_error_hours
    
    , o.shipping_address_uuid
    , a.country as shipping_country
    , a.state as shipping_state
    , a.zip_code as shipping_zip_code

    , o.tracking_id
    , o.shipping_service

from orders o
    inner join addresses a
        on o.shipping_address_uuid = a.address_uuid
    left join promos p
        on o.promo_name = p.promo_name
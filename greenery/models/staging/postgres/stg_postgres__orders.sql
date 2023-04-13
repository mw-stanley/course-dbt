with source as (
    select * from {{ source('postgres', 'orders') }}
)

, final as (
    select
        order_id as order_uuid
        , user_id as user_uuid
        , promo_id as promo_name
        , address_id as shipping_address_uuid
        , created_at
        , order_cost as order_cost_usd --I will assume everything is in USD
        , shipping_cost as shipping_cost_usd 
        , order_total as order_total_usd
        , tracking_id
        , shipping_service
        , estimated_delivery_at       
        , delivered_at
        , status
    from source
)

select * from final

with source as (
    select * from {{ source('postgres', 'order_items') }}
)

, final as (
    select
        order_id as order_uuid
        , product_id as product_uuid
        , quantity
    from source
)

select * from final
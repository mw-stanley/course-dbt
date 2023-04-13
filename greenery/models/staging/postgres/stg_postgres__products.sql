with source as (
    select * from {{ source('postgres', 'products') }}
)

, final as (
    select
        product_id as product_uuid
        , name as product_name
        , price as price_usd
        , inventory as inventory_amount
    from source
)

select * from final
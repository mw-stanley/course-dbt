with products as (
    select * from {{ ref('stg_postgres__products')}}
)

select
        product_uuid
        , product_name
        , price_usd --We are assuming the price doesn't change
        --, inventory --Dropped from this view, should be brought in from snapshot

from products
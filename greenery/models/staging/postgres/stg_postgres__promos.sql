with source as (
    select * from {{ source('postgres', 'promos') }}
)

, final as (
    select
        promo_id as promo_name
        , discount as discount_usd
        , status
    from source
)

select * from final
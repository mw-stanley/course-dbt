with source as (
    select * from {{ source('postgres', 'addresses') }}
)

, final as (
    SELECT
        address_id as address_uuid
        , address
        , lpad(zipcode, 5, 0) as zip_code
        , state
        , country
    from source
)

select * from final
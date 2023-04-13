with source as (
    select * from {{ source('postgres', 'users') }}
)

, final as (
    select
        user_id as user_uuid
        , first_name
        , last_name
        , email
        , phone_number
        , created_at
        , updated_at
        , address_id as address_uuid
    from source
)

select * from final
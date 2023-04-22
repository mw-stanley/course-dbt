with usrs as (
    select * from {{ref('stg_postgres__users')}}
)

, addresses as (
    select * from {{ ref('stg_postgres__addresses')}}
)

select
    u.user_uuid
    , u.first_name
    , u.last_name
    , u.email
    , u.phone_number
    , u.created_at
    , u.updated_at
    , u.address_uuid
    , a.address
    , a.zip_code
    , a.state
    , a.country
    
from usrs u
    inner join addresses a
        on u.address_uuid = a.address_uuid
with events as (
    select * from {{ref('stg_postgres__events')}}
)

select
    event_uuid
    , session_uuid
    , user_uuid
    , page_url
    , created_at
    , event_type
    , order_uuid
    , product_uuid
from events

where event_type = 'page_view'
with source as (
    select * from {{ source('postgres', 'events') }}
)

, final as (
    select
        event_id as event_uuid
        , session_id as session_uuid
        , user_id as user_uuid
        , page_url
        , created_at
        , event_type
        , order_id as order_uuid
        , product_id as product_uuid
    from source
)

select * from final
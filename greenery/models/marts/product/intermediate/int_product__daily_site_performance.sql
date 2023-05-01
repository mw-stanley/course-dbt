with events as (
    select * from {{ref('stg_postgres__events')}}
)

select
    e.product_uuid
    , e.created_at::date as dt
    {{ sum_all_event_types(table_name='stg_postgres__events', column_name='event_type') }}
from events e
where product_uuid is not null
group by 1,2
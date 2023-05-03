with events as (
    select * from {{ref('stg_postgres__events')}}
)

, order_products as (
    select * from {{ref('stg_postgres__order_items')}}
)

select
    coalesce(e.product_uuid, op.product_uuid) as product_uuid
    , e.created_at::date as dt
    {{ sum_all_event_types(table_name='stg_postgres__events', column_name='event_type') }}
from events e
left join order_products op on e.order_uuid = op.order_uuid
group by 1,2
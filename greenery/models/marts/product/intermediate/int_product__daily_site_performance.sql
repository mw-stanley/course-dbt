with events as (
    select * from {{ref('stg_postgres__events')}}
)

select
    e.product_uuid
    , e.created_at::date as dt
    , sum(case when e.event_type = 'page_view' then 1 else 0 end) as product_page_views
    , sum(case when e.event_type = 'add_to_cart' then 1 else 0 end) as product_add_to_carts   
from events e
where product_uuid is not null
group by 1,2
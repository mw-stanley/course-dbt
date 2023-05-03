with events as (
    select * from {{ ref('stg_postgres__events') }}
)

select 
    date_trunc(week, created_at)::date as wk
    , count(distinct session_uuid) as n_sessions
    , count(distinct case when event_type = 'page_view' then session_uuid else null end) as n_page_view_sessions
    , count(distinct case when event_type = 'add_to_cart' then session_uuid else null end) as n_add_to_cart_sessions
    , 1-(div0(n_add_to_cart_sessions::float, n_page_view_sessions)) as add_to_cart_dropoff
    , count(distinct case when event_type = 'checkout' then session_uuid else null end) as n_checkout_sessions
    , 1-(div0(n_checkout_sessions::float, n_add_to_cart_sessions)) as checkout_dropoff
from events
group by 1
order by 1
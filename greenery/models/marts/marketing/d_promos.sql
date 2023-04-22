with promos as (
    select * from {{ ref('stg_postgres__promos')}}
)

, promo_perf as (
    select * from {{ ref('int_marketing__promo_daily_performance')}}
)

, total_perf as (
    select
        promo_name
        , sum(n_orders) as n_orders
        , sum(total_discount_usd) as total_discount_usd
        , sum(total_revenue_usd) as total_revenue_usd
        , sum(n_users) as n_users
    from promo_perf
    group by 1
)

select
    pm.promo_name
    , pm.discount_usd
    , pm.status
    , tp.n_orders
    , tp.total_discount_usd
    , tp.total_revenue_usd
    , tp.n_users
    
from promos pm
    left join total_perf tp
        on pm.promo_name = tp.promo_name
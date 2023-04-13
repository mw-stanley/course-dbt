# Answers to Week 1 Question 4

## How many users do we have?

```
select count(distinct user_uuid) from dev_db.dbt_fangxianfugmailcom.stg_postgres__users
```

Answer: 130

## On average, how many orders do we receive per hour?

```
with hrs as (
    select 
        date_trunc('hour', created_at) as h
        , count(distinct order_uuid) as n
    from dev_db.dbt_fangxianfugmailcom.stg_postgres__orders
    group by 1
)

select avg(n) as avg_n
from hrs
```

Answer: 7.520833

## On average, how long does an order take from being placed to being delivered?

```
select avg(datediff('hour', created_at, delivered_at)) avg_delivery_hrs from dev_db.dbt_fangxianfugmailcom.stg_postgres__orders
```

Answer: 93.403279

## How many users have only made one purchase? Two purchases? Three+ purchases?

```
with user_orders as (
    select
        user_uuid
        , count(distinct order_uuid) as n_orders
    from dev_db.dbt_fangxianfugmailcom.stg_postgres__orders
    group by 1
)

select
    case 
        when n_orders = 1 then '1'
        when n_orders = 2 then '2'
        when n_orders > 2 then '3+'
        else 'unknown'
    end as cohort
    , count(distinct user_uuid) as n_users
from user_orders
group by 1
order by 1
```

Answer: 1 - 25, 2 - 28, 3+ - 71

## On average, how many unique sessions do we have per hour?

```
with hrs as (
    select 
        date_trunc('hour', created_at) as h
        , count(distinct session_uuid) as n
    from dev_db.dbt_fangxianfugmailcom.stg_postgres__events
    group by 1
)

select avg(n)
from hrs
```

Answer: 16.327586
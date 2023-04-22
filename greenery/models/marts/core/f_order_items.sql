
with order_items as (
    select * from {{ ref('stg_postgres__order_items')}}
)

select
    oi.order_uuid
    , oi.product_uuid
    , oi.quantity as quantity_purchased

from order_items oi
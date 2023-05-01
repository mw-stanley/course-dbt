# Part 1 - Models

## What is our overall conversion rate?

```
select count(distinct session_uuid) from f_page_views
;
select count(*) from f_orders
```
Gives `361/578 = 0.624`

## What is our conversion rate by product?
This is actually easier in my data model than the overall figure

```
select 
product_name
, sum(n_orders) / sum(product_page_views) as product_conversion_rate
from f_product_daily_performance
group by 1
```

```
PRODUCT_NAME	PRODUCT_CONVERSION_RATE
Bird of Paradise	0.45
Angel Wings Begonia	0.387097
Ficus	0.426471
Calathea Makoyana	0.509434
Cactus	0.545455
Orchid	0.453333
Ponytail Palm	0.394366
Devil's Ivy	0.488889
Dragon Tree	0.467742
Pothos	0.328125
Rubber Plant	0.5
Pilea Peperomioides	0.466667
Majesty Palm	0.478261
Bamboo	0.521739
Alocasia Polly	0.388889
Arrow Head	0.546875
ZZ Plant	0.523077
Birds Nest Fern	0.4125
Monstera	0.510204
Fiddle Leaf Fig	0.474576
Snake Plant	0.39726
Philodendron	0.47619
Pink Anthurium	0.418919
Jade Plant	0.478261
Boston Fern	0.412698
Peace Lily	0.402985
Aloe Vera	0.492308
Spider Plant	0.474576
Money Tree	0.464286
String of pearls	0.6
```

# Part 2 - macro

I used an event_types macro to simplify and expand my int_product__daily_site_performance model. This also future-proofs it against future event types.

# Part 3 - grant hook

I also tested using the `grants:` option in dbt_project.yml and this granted SELECT on the table but not USAGE on the schema, so I wasn't able to verify that this actually worked and so I commented it out.

# Part 4 - packages

I have tests from dbt_utils and dbt_expectations in the project. I also experimented with using dbt codegen to generate source yml files.

```
gitpod /workspace/course-dbt/greenery (main) $ dbt run-operation generate_source --args '{"schema_name": "public", "database_name": "raw", "exclude": "superheroes"}'
00:57:42  Running with dbt=1.4.5
00:57:44  version: 2

sources:
  - name: public
    database: raw
    tables:
      - name: addresses
      - name: events
      - name: order_items
      - name: orders
      - name: products
      - name: promos
      - name: users
gitpod /workspace/course-dbt/greenery (main) $ dbt run-operation generate_source --args '{"schema_name": "public", "database_name": "raw", "exclude": "superheroes", "generate_columns": true}'
00:58:41  Running with dbt=1.4.5
00:58:44  version: 2

sources:
  - name: public
    database: raw
    tables:
      - name: addresses
        columns:
          - name: address_id
          - name: address
          - name: zipcode
          - name: state
          - name: country

      - name: events
        columns:
          - name: event_id
          - name: session_id
          - name: user_id
          - name: page_url
          - name: created_at
          - name: event_type
          - name: order_id
          - name: product_id

      - name: order_items
        columns:
          - name: order_id
          - name: product_id
          - name: quantity

      - name: orders
        columns:
          - name: order_id
          - name: user_id
          - name: promo_id
          - name: address_id
          - name: created_at
          - name: order_cost
          - name: shipping_cost
          - name: order_total
          - name: tracking_id
          - name: shipping_service
          - name: estimated_delivery_at
          - name: delivered_at
          - name: status

      - name: products
        columns:
          - name: product_id
          - name: name
          - name: price
          - name: inventory

      - name: promos
        columns:
          - name: promo_id
          - name: discount
          - name: status

      - name: users
        columns:
          - name: user_id
          - name: first_name
          - name: last_name
          - name: email
          - name: phone_number
          - name: created_at
          - name: updated_at
          - name: address_id
```

# Part 5 - simplified DAG

My DAG is actually unchanged from last week but the process of building the model SQL is now more future-proof.

![Week 2 dag](week_2_dag.png)

# Part 6 - snapshots

```
select name from product_inventory_snapshot where dbt_valid_to is not null and dbt_valid_to > dateadd(day, -7, current_date)
```

```
NAME
Monstera
Pothos
Philodendron
String of pearls
Bamboo
ZZ Plant
```
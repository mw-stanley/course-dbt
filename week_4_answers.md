# Part 1 - snapshots

## Which products had their inventory change from week 3 to week 4? 

```
select name from product_inventory_snapshot where dbt_valid_to is not null and dbt_valid_to > current_date
```

```
NAME
Bamboo
String of pearls
ZZ Plant
Philodendron
Pothos
Monstera
```

(This query only works because I just ran the snapshot and I wouldn't recommend it most of the time!)

## Which products had the most fluctuations in inventory? 

```
with fluctuations as (
    select
        name
        , abs(lag(inventory) over (partition by product_id order by dbt_updated_at) - inventory) as inventory_fluctuation
    from product_inventory_snapshot 
    order by name, dbt_updated_at
)

select
    name
    , sum(inventory_fluctuation) as total_inventory_fluctuation
from fluctuations
group by 1
having total_inventory_fluctuation is not null
order by 2 desc
```

```
NAME	TOTAL_INVENTORY_FLUCTUATION
String of pearls	68
Pothos	60
Philodendron	51
ZZ Plant	48
Monstera	46
Bamboo	33
```

So String of pearls had the most inventory fluctuation.

## Did we have any items go out of stock in the last 3 weeks? 

```
select *
from (
    select 
        name
        , dbt_updated_at
        , lag(inventory) over (partition by product_id order by dbt_updated_at) as prior_inventory 
        , inventory
        , lead(inventory) over (partition by product_id order by dbt_updated_at) as next_inventory
    from product_inventory_snapshot 
)
where inventory = 0
```

```
NAME	DBT_UPDATED_AT	PRIOR_INVENTORY	INVENTORY	NEXT_INVENTORY
Pothos	2023-05-01 01:01:20.448	20	0	20
String of pearls	2023-05-01 01:01:20.448	10	0	10
```

So Pothos and String of Pearls both went out of stock in week 3 but were back in stock in week 4.

# Part 2 - funnel

I added a line to my sum_all_event_types macro that also returns the count of distinct sessions, then added the session counts to a new model, f_weekly_sales_funnel. I left this at the weekly grain so success can be tracked over time - daily seems too granular for this data as there are some inconsistencies with how sessions appear when using days. This needs to be a separate model to the one that includes product grain because sessions are duplicated across products and will be double-counted.

```
WK	N_SESSIONS	N_PAGE_VIEW_SESSIONS	N_ADD_TO_CART_SESSIONS	ADD_TO_CART_DROPOFF	N_CHECKOUT_SESSIONS	CHECKOUT_DROPOFF
2021-02-08	578	578	467	0.1920415225	361	0.2269807281
```

This shows that we have a 19.2% dropoff to add_to_cart and a 22.7% dropoff to checkout.

Looking at this on a per-product basis using f_weekly_product_sales_funnel, we can see the top and bottom few products by funnel dropoff. It's worth noting that in the real world, this weekly product-grain and total-grain aggregation might be better handled in a semantic layer. This view will work well as the basis for more dashboards and exploration.

## Highest Add to Cart Dropoff

```
select 
    wk
    , product_name
    , add_to_cart_dropoff
from f_weekly_product_sales_funnel
order by add_to_cart_dropoff desc
limit 3
```

```
WK	PRODUCT_NAME	ADD_TO_CART_DROPOFF
2021-02-08	Pothos	0.606557377
2021-02-08	Ponytail Palm	0.5714285714
2021-02-08	Money Tree	0.5357142857
```

## Lowest add to cart dropoff

```
select 
    wk
    , product_name
    , add_to_cart_dropoff
from f_weekly_product_sales_funnel
order by add_to_cart_dropoff asc
limit 3
```

```
WK	PRODUCT_NAME	ADD_TO_CART_DROPOFF
2021-02-08	String of pearls	0.3125
2021-02-08	Bamboo	0.3731343284
2021-02-08	Arrow Head	0.380952381
```

## Highest checkout dropoff

```
select 
    wk
    , product_name
    , checkout_dropoff
from f_weekly_product_sales_funnel
order by checkout_dropoff desc
limit 3
```

```
WK	PRODUCT_NAME	CHECKOUT_DROPOFF
2021-02-08	Angel Wings Begonia	0.25
2021-02-08	Boston Fern	0.2352941176
2021-02-08	Peace Lily	0.2285714286
```

## Lowest checkout dropoff

```
select 
    wk
    , product_name
    , checkout_dropoff
from f_weekly_product_sales_funnel
order by checkout_dropoff asc
limit 3
```

```
WK	PRODUCT_NAME	CHECKOUT_DROPOFF
2021-02-08	Money Tree	0
2021-02-08	ZZ Plant	0.02857142857
2021-02-08	Monstera	0.03846153846
```

## Exposure
The exposure is in _product__exposures.yml

# Part 3B - production

On reflection, I think that `dbt build` is actually the best option for running dbt projects in production. The pattern for `dbt build` is:

* run models
* test tests
* snapshot snapshots
* seed seeds

In DAG order. This is basically what I would do with individual dbt commands anyway, and I think that a basic organising principle for dbt projects should be "If it needs to run out of DAG order, it should be a separate dbt project". So for example, a dbt model that builds on the output of the `run_results.json` and `sources.json` of a dbt run should be a separate dbt project.

So the basic structure of the project automation is a series of `dbt build` commands run by the scheduler.

For CI, we can use the same `dbt build` command but override the target to a ci environment.
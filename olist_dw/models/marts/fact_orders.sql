-- File:        fact_orders.sql
-- Description: Fact table, grain = one row per order_item
--
-- Created at:  2026-10-08
-- Created by:  claude
-- Updated at:  2026-10-08
-- Updated by:  claude

-- Keys are hashed straight from natural ids: same hash as the dims, no join, no fan-out.
select
    i.order_id,
    i.order_item_seq,
    {{ dbt_utils.generate_surrogate_key(['o.customer_id']) }} as customer_key,
    {{ dbt_utils.generate_surrogate_key(['i.product_id']) }}  as product_key,
    {{ dbt_utils.generate_surrogate_key(['i.seller_id']) }}   as seller_key,
    to_char(o.purchased_at, 'YYYYMMDD')::int                  as date_key,
    o.order_status,
    o.purchased_at,
    o.delivered_at,
    i.price,
    i.freight_value,
    i.price + i.freight_value                                 as amount
from {{ ref('stg_order_items') }} i
join {{ ref('stg_orders') }} o using (order_id)

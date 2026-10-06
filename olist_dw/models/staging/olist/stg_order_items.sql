-- File:        stg_order_items.sql
-- Description: Staging view for raw.order_items
--
-- Created at:  2026-10-06
-- Created by:  claude
-- Updated at:  2026-10-06
-- Updated by:  claude

with source as (
    select * from {{ source('olist_raw', 'order_items') }}
),
renamed as (
    select
        order_id,
        order_item_id::int                          as order_item_seq,
        product_id,
        seller_id,
        nullif(shipping_limit_date, '')::timestamp  as shipping_limit_at,
        price::numeric                              as price,
        freight_value::numeric                      as freight_value
    from source
)
select * from renamed

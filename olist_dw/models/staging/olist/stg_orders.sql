-- File:        stg_orders.sql
-- Description: Staging view for raw.orders (rename + cast only)
--
-- Created at:  2026-10-06
-- Created by:  claude
-- Updated at:  2026-10-06
-- Updated by:  claude

with source as (
    select * from {{ source('olist_raw', 'orders') }}
),
renamed as (
    select
        order_id,
        customer_id,
        order_status,
        nullif(order_purchase_timestamp, '')::timestamp       as purchased_at,
        nullif(order_approved_at, '')::timestamp              as approved_at,
        nullif(order_delivered_carrier_date, '')::timestamp   as delivered_to_carrier_at,
        nullif(order_delivered_customer_date, '')::timestamp  as delivered_at,
        nullif(order_estimated_delivery_date, '')::timestamp  as estimated_delivery_at
    from source
)
select * from renamed

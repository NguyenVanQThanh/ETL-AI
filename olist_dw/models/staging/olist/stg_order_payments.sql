-- File:        stg_order_payments.sql
-- Description: Staging view for raw.order_payments
--
-- Created at:  2026-10-06
-- Created by:  claude
-- Updated at:  2026-10-06
-- Updated by:  claude

with source as (
    select * from {{ source('olist_raw', 'order_payments') }}
),
renamed as (
    select
        order_id,
        payment_sequential::int   as payment_seq,
        payment_type,
        payment_installments::int as installments,
        payment_value::numeric    as payment_value
    from source
)
select * from renamed

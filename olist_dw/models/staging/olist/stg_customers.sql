-- File:        stg_customers.sql
-- Description: Staging view for raw.customers
--
-- Created at:  2026-10-06
-- Created by:  claude
-- Updated at:  2026-10-06
-- Updated by:  claude

with source as (
    select * from {{ source('olist_raw', 'customers') }}
),
renamed as (
    select
        customer_id,
        customer_unique_id,
        lpad(customer_zip_code_prefix, 5, '0') as zip_code_prefix,
        customer_city  as city,
        customer_state as state
    from source
)
select * from renamed

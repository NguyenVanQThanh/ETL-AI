-- File:        dim_customer.sql
-- Description: Customer dimension (SCD1), one row per customer_id
--
-- Created at:  2026-10-08
-- Created by:  claude
-- Updated at:  2026-10-08
-- Updated by:  claude

select
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
    customer_id,
    customer_unique_id,
    zip_code_prefix,
    city,
    state
from {{ ref('stg_customers') }}

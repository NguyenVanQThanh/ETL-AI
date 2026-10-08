-- File:        dim_seller.sql
-- Description: Seller dimension (SCD1), one row per seller_id
--
-- Created at:  2026-10-08
-- Created by:  claude
-- Updated at:  2026-10-08
-- Updated by:  claude

select
    {{ dbt_utils.generate_surrogate_key(['seller_id']) }} as seller_key,
    seller_id,
    zip_code_prefix,
    city,
    state
from {{ ref('stg_sellers') }}

-- File:        stg_product_category_translation.sql
-- Description: Staging view for raw.product_category_translation
--
-- Created at:  2026-10-06
-- Created by:  claude
-- Updated at:  2026-10-06
-- Updated by:  claude

with source as (
    select * from {{ source('olist_raw', 'product_category_translation') }}
),
renamed as (
    select
        product_category_name         as category_name,
        product_category_name_english as category_name_en
    from source
)
select * from renamed

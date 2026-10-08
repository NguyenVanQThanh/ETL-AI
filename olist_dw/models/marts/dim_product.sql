-- File:        dim_product.sql
-- Description: Product dimension (SCD1), one row per product_id, with English category
--
-- Created at:  2026-10-08
-- Created by:  claude
-- Updated at:  2026-10-08
-- Updated by:  claude

select
    {{ dbt_utils.generate_surrogate_key(['p.product_id']) }} as product_key,
    p.product_id,
    p.category_name,
    t.category_name_en,
    p.name_length,
    p.description_length,
    p.photos_qty,
    p.weight_g,
    p.length_cm,
    p.height_cm,
    p.width_cm
from {{ ref('stg_products') }} p
left join {{ ref('stg_product_category_translation') }} t
    on p.category_name = t.category_name

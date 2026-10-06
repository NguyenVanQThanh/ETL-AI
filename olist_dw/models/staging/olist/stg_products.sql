-- File:        stg_products.sql
-- Description: Staging view for raw.products
--
-- Created at:  2026-10-06
-- Created by:  claude
-- Updated at:  2026-10-06
-- Updated by:  claude

with source as (
    select * from {{ source('olist_raw', 'products') }}
),
renamed as (
    select
        product_id,
        product_category_name            as category_name,
        product_name_lenght::int         as name_length,
        product_description_lenght::int  as description_length,
        product_photos_qty::int          as photos_qty,
        product_weight_g::numeric        as weight_g,
        product_length_cm::numeric       as length_cm,
        product_height_cm::numeric       as height_cm,
        product_width_cm::numeric        as width_cm
    from source
)
select * from renamed

-- File:        stg_geolocation.sql
-- Description: Staging view for raw.geolocation
--
-- Created at:  2026-10-06
-- Created by:  claude
-- Updated at:  2026-10-06
-- Updated by:  claude

with source as (
    select * from {{ source('olist_raw', 'geolocation') }}
),
renamed as (
    select
        lpad(geolocation_zip_code_prefix, 5, '0') as zip_code_prefix,
        geolocation_lat::numeric as lat,
        geolocation_lng::numeric as lng,
        geolocation_city         as city,
        geolocation_state        as state
    from source
)
select * from renamed

-- File:        dim_date.sql
-- Description: Date dimension, one row per day (covers Olist order range)
--
-- Created at:  2026-10-08
-- Created by:  claude
-- Updated at:  2026-10-08
-- Updated by:  claude

with spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2016-01-01' as date)",
        end_date="cast('2019-01-01' as date)"
    ) }}
)
select
    to_char(date_day, 'YYYYMMDD')::int         as date_key,
    date_day::date                             as full_date,
    extract(year from date_day)::int           as year,
    extract(quarter from date_day)::int        as quarter,
    extract(month from date_day)::int          as month,
    extract(day from date_day)::int            as day,
    extract(isodow from date_day)::int         as day_of_week,
    extract(isodow from date_day) in (6, 7)    as is_weekend
from spine

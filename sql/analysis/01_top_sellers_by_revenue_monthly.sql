-- File:        01_top_sellers_by_revenue_monthly.sql
-- Description: Top 5 sellers by revenue per month
-- Keywords:    CTE, ROW_NUMBER, PARTITION BY
--
-- Created at:  2026-10-10
-- Created by:  thanh
-- Updated at:  2026-10-14
-- Updated by:  thanh

/*
Return top 5 sellers by revenue per month, along with the revenue and rank of each seller within the month.

Field incluing: year, month, seller_key, city, state, revenue, rn. Sort by month -> rn

Table: marts.fact_orders, marts.dim_seller, marts.dim_date

Keyword: CTE, ROW_NUMBER(), PARTITION BY, GROUP BY ... DESC, rn <= 5
*/

with monthly_revenue as (
    select
        d.year,
        d.month,
        f.seller_key,
        sum(f.amount) as revenue
    from marts.fact_orders f
    join marts.dim_date d on f.date_key = d.date_key
    group by d.year, d.month, f.seller_key
),

ranked as (
    select 
    year,
    month,
    seller_key,
    revenue,
    ROW_NUMBER() OVER (
        PARTITION BY year, month
        order by revenue desc, seller_key
    ) as rn
    from monthly_revenue
)

select 
    r.year, r.month, 
    s.seller_id, 
    s.city, 
    s.state, 
    r.revenue, 
    r.rn
from ranked r
join marts.dim_seller s on r.seller_key = s.seller_key
where r.rn <= 5
order by r.year, r.month, r.rn;
    


-- File:        03_days_between_consecutive_orders.sql
-- Description: Days between two consecutive orders of the same customer
-- Keywords:    CTE, LAG, PARTITION BY, date subtraction
--
-- Created at:  2026-10-15
-- Created by:  thanh
-- Updated at:  2026-10-15
-- Updated by:  thanh

/*
For each order that is not the customer's first, return the number of days since the customer's previous order.

Fields including: customer_unique_id, order_id, purchased_at, prev_purchased_at, days_since_prev. Sort by customer_unique_id -> purchased_at -> order_id

Table: marts.fact_orders, marts.dim_customer

Keyword: CTE, LAG(), PARTITION BY customer_unique_id, date subtraction, prev_purchased_at IS NOT NULL

Note: same as query 02 but LAG over purchased_at instead of order_total.
      Aggregate items to one row per order first (min(purchased_at)).
*/

WITH orders_agg AS (
      SELECT
            c.customer_unique_id,
            f.order_id,
            MIN(f.purchased_at) AS purchased_at
      FROM marts.fact_orders f
      join marts.dim_customer c on f.customer_key = c.customer_key
      GROUP BY c.customer_unique_id, f.order_id
),
with_prev AS (
      SELECT 
            customer_unique_id,
            order_id,
            purchased_at,
            LAG(purchased_at) OVER (
                  PARTITION BY customer_unique_id
                  ORDER BY purchased_at, order_id
            ) AS prev_purchased_at
      FROM orders_agg
)

SELECT 
      customer_unique_id,
      order_id,
      purchased_at,
      prev_purchased_at,
      -- full 24h days, ignores time of day; keep consistent with query 04
      EXTRACT(DAY FROM purchased_at - prev_purchased_at) AS days_since_prev
FROM with_prev
WHERE prev_purchased_at IS NOT NULL
ORDER BY customer_unique_id, purchased_at, order_id;
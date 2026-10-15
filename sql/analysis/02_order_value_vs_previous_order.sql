-- File:        02_order_value_vs_previous_order.sql
-- Description: Order value compared with the same customer's previous order
-- Keywords:    CTE, LAG, PARTITION BY
--
-- Created at:  2026-10-14
-- Created by:  thanh
-- Updated at:  2026-10-15
-- Updated by:  thanh

/*
For each order, return its total value, the total of the same customer's previous order, and the difference.

Fields including: customer_unique_id, order_id, purchased_at, order_total, prev_total, diff. Sort by customer_unique_id -> purchased_at -> order_id

Table: marts.fact_orders, marts.dim_customer

Keyword: CTE, LAG(), PARTITION BY customer_unique_id, prev_total IS NOT NULL

Note: fact_orders grain is one row per order item -> aggregate to one row per order first.
      customer_key changes per order -> partition by customer_unique_id.
*/

WITH orders_agg AS (
      SELECT
            c.customer_unique_id,
            f.order_id,
            MIN(f.purchased_at) AS purchased_at,
            SUM(f.amount) AS order_total
      FROM marts.fact_orders f
      join marts.dim_customer c on f.customer_key = c.customer_key
      GROUP BY c.customer_unique_id, f.order_id
),
with_prev AS (
      SELECT
            customer_unique_id,
            order_id,
            purchased_at,
            order_total,
            LAG(order_total) OVER (
                  PARTITION BY customer_unique_id
                  ORDER BY purchased_at, order_id
            ) AS prev_total
      FROM orders_agg
)

SELECT 
      customer_unique_id, 
      order_id, 
      purchased_at, 
      order_total, 
      prev_total, 
      order_total - prev_total as diff
FROM with_prev
WHERE prev_total IS NOT NULL
ORDER BY customer_unique_id, purchased_at, order_id;
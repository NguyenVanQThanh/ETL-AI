-- File:        04_next_order_and_30d_return_rate.sql
-- Description: Next order of the same customer and the 30-day return rate
-- Keywords:    CTE, LEAD, COALESCE, FILTER
--
-- Created at:  2026-10-19
-- Created by:  thanh
-- Updated at:  2026-10-22
-- Updated by:  thanh

/*
Part A: for each order, return the purchase time of the same customer's next order and whether the customer came back within 30 days.

Fields including: customer_unique_id, order_id, purchased_at, next_purchased_at, days_to_next, returned_30d. Sort by customer_unique_id -> purchased_at -> order_id

Part B: the 30-day return rate = orders followed by another order within 30 days / all orders.

Table: marts.fact_orders, marts.dim_customer

Keyword: CTE, LEAD(), PARTITION BY customer_unique_id, COALESCE, FILTER (WHERE ...)

Note: the customer's last order has no next order (NULL) -> "not returned", count it as false, not as missing.
      Use EXTRACT(DAY FROM ...) for days, same as query 03.
*/

-- Part A
WITH orders_agg AS (
      SELECT
            c.customer_unique_id,
            f.order_id,
            MIN(f.purchased_at) AS purchased_at
      FROM marts.fact_orders f
      JOIN marts.dim_customer c ON f.customer_key = c.customer_key
      GROUP BY c.customer_unique_id, f.order_id
),
with_next AS (
      SELECT
            customer_unique_id,
            order_id,
            purchased_at,
            LEAD(purchased_at) OVER (
                  PARTITION BY customer_unique_id
                  ORDER BY purchased_at, order_id
            ) AS next_purchased_at
      FROM orders_agg
)

SELECT
      customer_unique_id,
      order_id,
      purchased_at,
      next_purchased_at,
      -- full 24h days, ignores time of day; same as query 03
      EXTRACT(DAY FROM next_purchased_at - purchased_at) AS days_to_next,
      -- NULL next order -> comparison is NULL -> COALESCE to false (last order = not returned)
      COALESCE(EXTRACT(DAY FROM next_purchased_at - purchased_at) <= 30, FALSE) AS returned_30d
FROM with_next
ORDER BY customer_unique_id, purchased_at, order_id;

-- Part B
WITH orders_agg AS (
      SELECT
            c.customer_unique_id,
            f.order_id,
            MIN(f.purchased_at) AS purchased_at
      FROM marts.fact_orders f
      JOIN marts.dim_customer c ON f.customer_key = c.customer_key
      GROUP BY c.customer_unique_id, f.order_id
),
with_next AS (
      SELECT
            purchased_at,
            LEAD(purchased_at) OVER (
                  PARTITION BY customer_unique_id
                  ORDER BY purchased_at, order_id
            ) AS next_purchased_at
      FROM orders_agg
)

SELECT
      COUNT(*)                                                                      AS total_orders,
      COUNT(*) FILTER (WHERE EXTRACT(DAY FROM next_purchased_at - purchased_at) <= 30) AS returned_30d_orders,
      ROUND(
            COUNT(*) FILTER (WHERE EXTRACT(DAY FROM next_purchased_at - purchased_at) <= 30)::numeric
            / COUNT(*),
            4
      )                                                                             AS return_rate_30d
FROM with_next;

-- File:        04_next_order_and_30d_return_rate.sql
-- Description: Next order of the same customer and the 30-day return rate
-- Keywords:    CTE, LEAD, COALESCE, FILTER
--
-- Created at:  2026-10-19
-- Created by:  thanh
-- Updated at:  2026-10-19
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


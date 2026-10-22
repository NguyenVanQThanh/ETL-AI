-- File:        06_cohort_retention_month_plus_1.sql
-- Description: Monthly cohort retention - customers whose first order is in month M and who buy again in month M+1
-- Keywords:    CTE, MIN, date_trunc, COUNT(DISTINCT)
--
-- Created at:  2026-10-22
-- Created by:  thanh
-- Updated at:  2026-10-22
-- Updated by:  thanh

/*
Retention: group customers by the month of their first order (cohort), then count how many of them
also ordered in the following calendar month.

Fields including: cohort_month, cohort_size, retained_m1, retention_m1_rate. Sort by cohort_month

Table: marts.fact_orders, marts.dim_customer

Keyword: CTE, MIN(), date_trunc('month'), COUNT(DISTINCT)

Note: the rate is very low (~0.5% per cohort; only ~3% of customers ever reorder), that is the correct result.
      Tiny cohorts (2016-08, 2016-11) and the last cohort (2018-07, no M+1 data yet) are not meaningful.
*/

WITH customer_months AS (
      -- one row per customer per month with at least one order
      SELECT DISTINCT
            c.customer_unique_id,
            date_trunc('month', f.purchased_at)::date AS order_month
      FROM marts.fact_orders f
      JOIN marts.dim_customer c ON f.customer_key = c.customer_key
),
cohorts AS (
      SELECT
            customer_unique_id,
            MIN(order_month) AS cohort_month
      FROM customer_months
      GROUP BY customer_unique_id
)

SELECT
      co.cohort_month,
      COUNT(DISTINCT co.customer_unique_id) AS cohort_size,
      COUNT(DISTINCT cm.customer_unique_id) AS retained_m1,
      ROUND(COUNT(DISTINCT cm.customer_unique_id)::numeric / COUNT(DISTINCT co.customer_unique_id), 4) AS retention_m1_rate
FROM cohorts co
-- LEFT JOIN keeps cohorts with zero retained customers
LEFT JOIN customer_months cm
      ON cm.customer_unique_id = co.customer_unique_id
      AND cm.order_month = (co.cohort_month + INTERVAL '1 month')::date
GROUP BY co.cohort_month
ORDER BY co.cohort_month;

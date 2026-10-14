# SQL Analysis — kiến thức P1.S5

Kiến thức nền cho buổi [P1.S05 — SQL thực hành trên mart](../../tracker/phase-1/P1.S05-sql-thuc-hanh-mart.md).
Ví dụ chạy thật trên schema `marts` (Olist, Postgres) ngày 2026-10-08.

## Cấu trúc mỗi file

1. **Lý thuyết** — khái niệm, cú pháp
2. **Ví dụ trong DB** — query + output thật
3. **Đề bài & keyword** — case áp dụng cho S5
4. **Bẫy** — lỗi âm thầm hay gặp

## Mục lục

| File | Nội dung | Đề S5 liên quan |
|---|---|---|
| [01-window-function.md](01-window-function.md) | `OVER`, `PARTITION BY`, so với `GROUP BY` | nền cho mọi đề |
| [02-ranking.md](02-ranking.md) | `ROW_NUMBER`, `RANK`, `DENSE_RANK` | 01, 05 |
| [03-lag-lead.md](03-lag-lead.md) | `LAG`, `LEAD` | 02, 03, 04 |
| [04-running-total.md](04-running-total.md) | `SUM() OVER`, frame, tổng luỹ kế | 07, 10 |
| [05-cte.md](05-cte.md) | `WITH`, tách bước | 01, 02, 06, 09, 10 |
| [06-exists-in-join.md](06-exists-in-join.md) | `EXISTS`, `IN`, `JOIN`, bẫy `NOT IN` | 08, 09 |
| [07-explain-index.md](07-explain-index.md) | `EXPLAIN ANALYZE`, index | bước 3–4 của S5 |
| [08-de-bai-s5.md](08-de-bai-s5.md) | 10 đề, đã chỉnh cho đúng schema | tất cả |

## Đặc điểm data Olist cần nhớ

- `marts.fact_orders` grain = **1 dòng = 1 order_item**, không phải 1 đơn.
- `customer_id` mỗi đơn một giá trị. Người thật = `dim_customer.customer_unique_id`.
- Chỉ ~3% khách (2.913 / 95.420) mua lại.
- Data đơn từ 2016-09 đến 2018-10; tháng 11/2016 không có đơn.
- `order_reviews` và `estimated_delivery_at` nằm ở `staging`, chưa vào marts.

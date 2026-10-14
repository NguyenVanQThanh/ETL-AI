# 08 — 10 đề bài S5 (đã chỉnh cho schema thật)

Spec gốc: [P1.S05](../../tracker/phase-1/P1.S05-sql-thuc-hanh-mart.md). Bảng dưới đã sửa các chỗ không khớp `marts` của project.

File đầu ra: `sql/analysis/NN_<tên>.sql`. Mỗi file có comment đầu nêu mục đích + keyword.

| # | Đề bài | Keyword | Bảng cần | Bẫy với data của bạn |
|---|---|---|---|---|
| 01 | Top 5 seller theo doanh thu mỗi tháng | CTE, `ROW_NUMBER`, `PARTITION BY`, lọc `rn <= 5` | `fact_orders`, `dim_seller`, `dim_date` | Thêm cột phụ vào `ORDER BY` để ổn định khi hoà |
| 02 | Giá trị đơn hiện tại so với đơn ngay trước của cùng khách | CTE, `LAG`, `PARTITION BY` | `fact_orders`, `dim_customer` | Gộp item thành đơn trước. Partition theo `customer_unique_id` |
| 03 | Số ngày giữa hai đơn liên tiếp của cùng khách | `LAG`, trừ ngày | như 02 | Lọc `prev IS NULL`. Chỉ ~3% khách có dữ liệu |
| 04 | Đơn kế tiếp của khách; tỉ lệ quay lại trong 30 ngày | `LEAD`, `COALESCE`, `FILTER` | như 02 | Dòng cuối của khách = "chưa quay lại" |
| 05 | So sánh `ROW_NUMBER`, `RANK`, `DENSE_RANK` trong một query | ba hàm ranking | `fact_orders`, `dim_seller` | Xếp theo số món (hoặc doanh thu làm tròn) mới thấy khác biệt |
| 06 | Retention: khách có đơn đầu ở tháng M, còn mua ở tháng M+1 | CTE, `MIN`, `date_trunc`, `COUNT(DISTINCT)` | `fact_orders`, `dim_customer` | Tỉ lệ rất thấp (~3%), đó là kết quả đúng |
| 07 | Doanh thu luỹ kế theo tháng | `SUM() OVER (ORDER BY)`, window trên aggregate | `fact_orders`, `dim_date` | Tháng 11/2016 vắng. Cần đủ tháng thì `left join` từ `dim_date` |
| 08 | Đơn không có review | `NOT EXISTS`, `NOT IN`, `LEFT JOIN ... IS NULL` | `fact_orders`, **`staging.stg_order_reviews`** | Review chưa ở marts. Viết cả ba cách, so sánh kết quả |
| 09 | Seller có ít nhất 1 đơn giao trễ, kèm tỉ lệ trễ | `EXISTS`, CTE, `FILTER`, `JOIN` | `fact_orders`, `dim_seller`, **`staging.stg_orders`** | Trễ = `delivered_at > estimated_delivery_at`. Đơn chưa giao không tính trễ |
| 10 | % doanh thu mỗi category trên tổng | CTE, `SUM() OVER ()`, `COALESCE`, `round` | `fact_orders`, `dim_product` | `category_name_en`; 610 sản phẩm không category → `unknown` |

## Thứ tự làm đề xuất

`01 → 05 → 02 → 03 → 07 → 10 → 04 → 06 → 08 → 09`

Đi từ ranking đơn giản đến cần gộp cấp đơn, rồi đến nhiều bảng.

## Quy trình mỗi đề

1. Mô tả bằng lời: một dòng kết quả đại diện cái gì (grain).
2. Viết CTE bước 1, chạy riêng, xem kết quả.
3. Thêm window function.
4. Kiểm số dòng: có hợp lý không, có NULL bất thường không.

## Sau khi đủ 10 file

Chọn 2–3 query nặng nhất, làm `EXPLAIN ANALYZE` trước và sau khi thử index: xem [07-explain-index.md](07-explain-index.md).

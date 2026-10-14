# 03 — LAG và LEAD

## 1. Lý thuyết

- `LAG(cột, n)` lấy giá trị của dòng **trước** n dòng (mặc định 1).
- `LEAD(cột, n)` lấy giá trị của dòng **sau** n dòng.
- Tính trong từng partition, theo `ORDER BY` của `OVER`.
- Dòng đầu (với LAG) hoặc dòng cuối (với LEAD) trả `NULL`. Truyền giá trị mặc định: `LAG(cột, 1, 0)` hoặc bọc `COALESCE`.
- Thay cho self-join khi so sánh kỳ này với kỳ trước.

```sql
lag(order_value) over (partition by customer_unique_id order by purchased_at)
```

## 2. Ví dụ trong DB

Một khách thật có 3 đơn. Phải gộp item lên cấp đơn trước:

```sql
with orders_lvl as (
  select c.customer_unique_id, f.order_id,
         min(f.purchased_at) purchased_at, sum(f.amount) order_value
  from marts.fact_orders f
  join marts.dim_customer c using (customer_key)
  group by 1, 2)
select customer_unique_id, order_id, purchased_at::date, order_value,
       lag(order_value) over (partition by customer_unique_id order by purchased_at) prev_value
from orders_lvl
where customer_unique_id = '6eefa309faab7725bf4b9dce147e4ae6'
order by purchased_at;
```
```
purchased_at | order_value | prev_value
2017-08-01   |   25.00     | NULL
2017-12-17   |   31.75     | 25.00
2018-01-04   |   30.85     | 31.75
```

## 3. Đề bài & keyword

| Đề | Keyword |
|---|---|
| 02 Giá trị đơn so với đơn ngay trước | CTE, `LAG`, `PARTITION BY customer_unique_id` |
| 03 Số ngày giữa hai đơn liên tiếp | `LAG(purchased_at)`, trừ ngày, lọc `prev IS NULL` |
| 04 Đơn kế tiếp, quay lại trong 30 ngày | `LEAD`, `COALESCE`, `FILTER` |

## 4. Bẫy

- **Partition theo `customer_unique_id`, không phải `customer_id`.** `customer_id` mỗi đơn một giá trị → `LAG` luôn `NULL`.
- Fact là cấp order_item. Gộp lên cấp đơn trước, không thì `LAG` so sánh item với item.
- Chỉ **2.913 / 95.420** khách (~3%) có từ 2 đơn trở lên. Ít dòng là bình thường.
- Dòng cuối của khách với `LEAD` là `NULL` = "chưa quay lại", không phải lỗi.

# 06 — EXISTS, IN, JOIN

## 1. Lý thuyết

| Cách | Dùng khi | Đặc điểm |
|---|---|---|
| `EXISTS` | Chỉ cần biết có hay không | Dừng ngay khi thấy 1 dòng khớp |
| `IN` | So với một danh sách ngắn | Dựng cả danh sách rồi so |
| `JOIN` | Cần lấy thêm cột từ bảng kia | Có thể nhân dòng nếu bảng kia nhiều dòng khớp |

Ba cách tìm "A không có B":
```sql
-- 1. NOT EXISTS (an toàn)
select o.* from orders o
where not exists (select 1 from reviews r where r.order_id = o.order_id);

-- 2. LEFT JOIN ... IS NULL
select o.* from orders o
left join reviews r on r.order_id = o.order_id
where r.order_id is null;

-- 3. NOT IN (có bẫy)
select o.* from orders o
where o.order_id not in (select order_id from reviews);
```

## 2. Ví dụ bẫy `NOT IN`

```sql
select 1 where 5 not in (1, 2, null);
-- ra 0 dòng, dù 5 không nằm trong 1, 2
```
Một `NULL` trong danh sách con làm mọi phép `NOT IN` thành "không biết" (UNKNOWN), kết quả rỗng và **không báo lỗi**.

## 3. Đề bài & keyword

| Đề | Keyword |
|---|---|
| 08 Đơn không có review | `NOT EXISTS`, `NOT IN`, `LEFT JOIN ... IS NULL`. Viết cả ba, so sánh kết quả |
| 09 Seller có ít nhất 1 đơn giao trễ | `EXISTS`, `JOIN`, CTE, `FILTER` |

## 4. Bẫy

- `review` nằm ở `staging.stg_order_reviews`, chưa có trong `marts`.
- `stg_order_reviews.order_id` đã có test `not_null`, nên `NOT IN` ở đây ra cùng kết quả với `NOT EXISTS`. Nhưng đừng dựa vào đó, hãy viết `NOT EXISTS` làm mặc định.
- "Trễ" = `delivered_at > estimated_delivery_at`. Đơn chưa giao (`delivered_at` NULL) không tính là trễ.
- `estimated_delivery_at` có ở `staging.stg_orders`, không có trong fact.

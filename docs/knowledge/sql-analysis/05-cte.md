# 05 — CTE (`WITH`)

## 1. Lý thuyết

CTE (Common Table Expression) là subquery **có tên**, đặt trước query chính.

```sql
with a as (...),
     b as (select ... from a)
select ... from b;
```

- Đọc từ trên xuống, từng bước, dễ kiểm tra riêng.
- Dùng lại được nhiều lần trong cùng query.
- `WITH RECURSIVE` dùng cho dữ liệu dạng cây (ít gặp trên mart phẳng).
- Postgres 12 trở lên thường inline CTE, không còn là "hàng rào tối ưu" như bản cũ.

## 2. Ví dụ trong DB

Gộp item lên cấp đơn, rồi tính trung bình:

```sql
with order_lvl as (
    select order_id, sum(amount) as order_value
    from marts.fact_orders
    group by 1
)
select round(avg(order_value), 2) from order_lvl;
```

Mẫu hay dùng nhất ở S5: **CTE 1 gộp cấp đơn → CTE 2 thêm window function → query ngoài lọc.**

## 3. Đề bài & keyword

| Đề | Dùng CTE để |
|---|---|
| 01 | Gộp doanh thu theo seller/tháng, rồi xếp hạng, rồi lọc top 5 |
| 02 | Gộp item thành đơn trước khi `LAG` |
| 06 | CTE 1: tháng đơn đầu của khách. CTE 2: đếm khách còn active tháng sau |
| 09 | Tổng hợp tỉ lệ trễ theo seller |
| 10 | Tính tổng doanh thu toàn shop |

## 4. Cách làm

1. Viết CTE bước 1, **chạy riêng**, xem kết quả.
2. Mới thêm bước 2 lên trên.
3. Lỗi thì biết ngay lỗi ở bước nào.

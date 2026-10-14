# 02 — ROW_NUMBER, RANK, DENSE_RANK

## 1. Lý thuyết

Cả ba đánh số thứ tự theo `ORDER BY`. Khác nhau khi có giá trị bằng nhau:

| Hàm | Ba giá trị bằng nhau, rồi giá trị kế |
|---|---|
| `ROW_NUMBER` | 1, 2, 3, 4 (luôn khác nhau) |
| `RANK` | 1, 1, 1, 4 (nhảy số) |
| `DENSE_RANK` | 1, 1, 1, 2 (không nhảy) |

Chọn hàm:
- Cần đúng N dòng mỗi nhóm → `ROW_NUMBER`.
- Hoà thì cùng hạng → `RANK` / `DENSE_RANK`.

## 2. Ví dụ trong DB

Seller theo số món bán trong tháng 1/2018:

```sql
select seller_id, n,
       row_number() over (order by n desc) rn,
       rank()       over (order by n desc) rk,
       dense_rank() over (order by n desc) dr
from (select f.seller_key as seller_id, count(*) n
      from marts.fact_orders f join marts.dim_date d using(date_key)
      where d.year = 2018 and d.month = 1 group by 1) t;
```
```
n  | rn | rk | dr
50 | 26 | 26 | 24
50 | 27 | 26 | 24
50 | 28 | 26 | 24
48 | 29 | 29 | 25   <- rank nhảy 26 -> 29, dense_rank chỉ 24 -> 25
```

## 3. Đề bài & keyword

| Đề | Keyword |
|---|---|
| 01 Top 5 seller doanh thu mỗi tháng | CTE, `ROW_NUMBER`, `PARTITION BY month`, lọc `rn <= 5` |
| 05 So sánh ba hàm trong một query | `ROW_NUMBER`, `RANK`, `DENSE_RANK` |

## 4. Bẫy

- `ROW_NUMBER` với giá trị hoà: thứ tự giữa các dòng hoà là **tuỳ ý**, kết quả đổi giữa các lần chạy. Thêm cột phụ vào `ORDER BY` (ví dụ `seller_id`) để ổn định.
- Doanh thu dạng số thập phân hiếm khi hoà → đề 05 xếp theo **số món** hoặc doanh thu làm tròn mới thấy khác biệt.

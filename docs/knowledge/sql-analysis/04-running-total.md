# 04 — Running total và tỉ trọng

## 1. Lý thuyết

**Running total (luỹ kế):** `SUM(...) OVER (ORDER BY ...)` cộng dồn từ dòng đầu đến dòng hiện tại.

Có thể bọc quanh một aggregate: `sum(sum(x)) over (order by m)`. Phép `sum(x)` bên trong gộp theo `GROUP BY` trước, window `sum` bên ngoài cộng dồn kết quả đó.

**Frame:** phạm vi dòng mà window nhìn thấy.
```sql
sum(x) over (order by m rows between unbounded preceding and current row)
```
Không ghi frame mà có `ORDER BY` thì mặc định là từ đầu đến dòng hiện tại (kiểu `RANGE`, các dòng cùng giá trị `ORDER BY` được tính chung).

**Tỉ trọng:** `SUM(x) OVER ()` (không partition) = tổng cả bảng trên mỗi dòng. Chia cho nó ra phần trăm.

## 2. Ví dụ trong DB

```sql
select d.year, d.month, round(sum(f.amount)) revenue,
       round(sum(sum(f.amount)) over (order by d.year, d.month)) running_total
from marts.fact_orders f join marts.dim_date d using (date_key)
group by 1, 2 order by 1, 2;
```
```
year | month | revenue | running_total
2016 |   9   |    355  |      355
2016 |  10   |  56809  |    57164
2016 |  12   |     20  |    57183     <- không có tháng 11
2017 |   1   | 137188  |   194372
```

## 3. Đề bài & keyword

| Đề | Keyword |
|---|---|
| 07 Doanh thu luỹ kế theo tháng | `SUM() OVER (ORDER BY ...)`, window trên aggregate, `ROWS BETWEEN` |
| 10 % doanh thu mỗi category | `SUM() OVER ()` không partition, `round`, `COALESCE` |

## 4. Bẫy

- Tháng 11/2016 không có đơn nên mất khỏi kết quả. Cần đủ tháng thì `left join` từ `dim_date`.
- Chia cho `SUM() OVER ()` là chia số nguyên nếu cả hai là integer. Dữ liệu `numeric` thì không sao, nếu không thì cast `::numeric`.
- 610 sản phẩm không có category → `COALESCE(category_name_en, 'unknown')`.

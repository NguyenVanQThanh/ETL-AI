# 01 — Window function

## 1. Lý thuyết

`GROUP BY` gộp nhiều dòng thành một. **Window function** tính trên một nhóm dòng nhưng **giữ nguyên từng dòng**.

```sql
<hàm>(...) OVER (
    PARTITION BY <cột chia nhóm>
    ORDER BY <cột sắp xếp trong nhóm>
)
```

| Thành phần | Vai trò |
|---|---|
| `OVER (...)` | Khai báo "cửa sổ" |
| `PARTITION BY` | Chia nhóm (bỏ đi = cả bảng là một nhóm) |
| `ORDER BY` trong `OVER` | Thứ tự tính trong nhóm (cần cho rank, LAG, running total) |

Hàm dùng được: aggregate (`SUM`, `AVG`, `COUNT`), ranking (`ROW_NUMBER`...), value (`LAG`, `LEAD`).

## 2. Ví dụ trong DB

Một đơn có 3 món, mỗi dòng vẫn còn nhưng đều kèm tổng của cả đơn:

```sql
select order_id, order_item_seq, amount,
       sum(amount) over (partition by order_id) as order_total
from marts.fact_orders
where order_id = '00143d0f86d6fbd9f9b38ab440ac16f5';
```
```
order_id | order_item_seq | amount | order_total
00143d.. |       1        | 36.43  | 109.29
00143d.. |       2        | 36.43  | 109.29
00143d.. |       3        | 36.43  | 109.29
```
`GROUP BY order_id` chỉ trả 1 dòng.

## 2b. GROUP BY vs window: so sánh trực tiếp

Cùng bài toán: tổng tiền của mỗi đơn, trên `marts.fact_orders` (112.650 dòng, 98.666 đơn).

**Cách 1: `GROUP BY`**
```sql
select order_id, sum(amount) order_total, count(*) n_items
from marts.fact_orders
group by order_id;
```
```
order_id | order_total | n_items
00143d.. |   109.29    |    3
0008288a |   126.54    |    2
```
Mỗi đơn còn **1 dòng**. Mất cột `order_item_seq`, `amount` của từng món.

**Cách 2: window function**
```sql
select order_id, order_item_seq, amount,
       sum(amount) over (partition by order_id) order_total,
       round(amount / sum(amount) over (partition by order_id) * 100, 1) pct_of_order
from marts.fact_orders;
```
```
order_id | seq | amount | order_total | pct_of_order
0008288a |  1  | 63.27  |   126.54    |    50.0
0008288a |  2  | 63.27  |   126.54    |    50.0
00143d.. |  1  | 36.43  |   109.29    |    33.3
00143d.. |  2  | 36.43  |   109.29    |    33.3
00143d.. |  3  | 36.43  |   109.29    |    33.3
```
Mọi dòng **còn nguyên**, kèm tổng của đơn. Tính được tỉ lệ từng món trong đơn mà không cần join lại.

| | `GROUP BY` | Window |
|---|---|---|
| Số dòng kết quả | 98.666 (một dòng một đơn) | 112.650 (giữ nguyên) |
| Cột chi tiết từng món | Mất | Còn |
| Thêm cột tổng vào từng dòng | Phải self-join | Một biểu thức |
| Lọc kết quả | `HAVING` | Bọc CTE rồi `WHERE` |

**Muốn giữ chi tiết với `GROUP BY` thì phải self-join:**
```sql
select f.order_id, f.amount, t.total
from marts.fact_orders f
join (select order_id, sum(amount) total from marts.fact_orders group by 1) t using (order_id);
```

### Plan thật (`EXPLAIN ANALYZE`)

| Cách | Node chính | Thời gian |
|---|---|---|
| `GROUP BY` | `HashAggregate` | 76 ms |
| Window | `Sort` (theo `order_id`) rồi `WindowAgg` | 134 ms |
| `GROUP BY` + self-join | `HashAggregate` + `Hash Join` (đọc bảng 2 lần) | 142 ms |

- Window **chậm hơn** `GROUP BY` thuần vì phải sắp xếp cả bảng theo `PARTITION BY`. Nhưng hai cách đó trả kết quả khác nhau, nên không so được trực tiếp.
- So đúng cặp (cùng giữ chi tiết): window 134 ms vs self-join 142 ms. Window gọn hơn một chút và chỉ đọc bảng một lần.
- Cả hai đều dùng ổ đĩa (`Disk: 5520kB`, `Disk Usage: 7464kB`) vì `work_mem` mặc định nhỏ. Với data này vẫn dưới 150 ms.
- Số đo trên máy của bạn, một lần chạy, chỉ để thấy cấu trúc plan, không phải benchmark.

**Chọn cách nào:**
- Chỉ cần tổng theo nhóm → `GROUP BY`.
- Cần tổng kèm từng dòng chi tiết (tỉ lệ, so với trung bình nhóm, xếp hạng, dòng trước) → window.

## 3. Đề bài & keyword

- Mọi đề từ 01 đến 07 và 10 dùng window function.
- Keyword: `OVER`, `PARTITION BY`, `ORDER BY`.

## 4. Bẫy

- Quên `PARTITION BY` → hàm tính xuyên cả bảng, sai âm thầm (không báo lỗi). Chạy thật:
  ```sql
  select order_id, order_item_seq, amount,
         sum(amount) over ()                      wrong_no_partition,
         sum(amount) over (partition by order_id) right_total
  from marts.fact_orders;
  ```
  ```
  order_id | seq | amount | wrong_no_partition | right_total
  00143d.. |  1  | 36.43  |    15843553.24     |   109.29
  ```
  `15.843.553` là tổng toàn bảng. Số này vẫn hợp lệ nên không có lỗi nào báo ra.
- Window chạy **sau** `WHERE`. Lọc `where order_id = '...'` ngay trong query đó thì `over ()` chỉ thấy 3 dòng và ra đúng số, che mất lỗi. Muốn thấy bẫy thì lọc ở query ngoài (bọc subquery).
- Không dùng được window function trong `WHERE`. Muốn lọc theo kết quả của nó thì bọc CTE rồi lọc ở query ngoài.

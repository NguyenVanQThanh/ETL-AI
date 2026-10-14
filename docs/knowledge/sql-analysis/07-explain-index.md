# 07 — EXPLAIN ANALYZE và index

> Phần lý thuyết, chưa chạy thực tế. Số liệu thật sẽ ghi vào đây khi làm bước 3–4 của S5.

## 1. Lý thuyết

`EXPLAIN` cho plan **ước tính**. `EXPLAIN ANALYZE` chạy query **thật** và thêm số đo thật.

```sql
explain analyze
select ... ;
```

Đọc một node của plan:
```
Seq Scan on fact_orders  (cost=0.00..2500.00 rows=112650 width=64)
                         (actual time=0.02..15.3 rows=112650 loops=1)
```

| Trường | Ý nghĩa |
|---|---|
| `Seq Scan` / `Index Scan` | Đọc toàn bảng tuần tự / nhảy theo index |
| `cost=a..b` | Chi phí ước tính, đơn vị tương đối (không phải giây). `a` = dòng đầu, `b` = tất cả |
| `rows` (ước tính) | Số dòng planner đoán |
| `actual time=a..b` | Mili giây thật |
| `rows` (actual) | Số dòng thật |
| `loops` | Số lần node chạy; nhân `actual time` với `loops` |

`rows` ước tính lệch xa `rows` thật → statistics cũ → chạy `ANALYZE <bảng>;`.

## 2. Index

- B-tree index hợp **tìm 1 đến vài dòng** theo điều kiện chọn lọc cao.
- Không hợp aggregation quét rộng kiểu OLAP.
- Bảng nhỏ (mart Olist ~112k dòng): Seq Scan thường rẻ hơn, planner **chọn đúng** khi bỏ qua index.
- Nguyên tắc: viết query không index → đo → chỉ thêm index khi đo thấy cải thiện rõ. Không thêm "phòng khi".

```sql
create index idx_fact_orders_seller on marts.fact_orders (seller_key);
```

## 3. Đề bài & keyword

- Chọn 2–3 query nặng nhất (gợi ý: 06, 09, 10).
- Ghi plan **trước** khi đổi gì, rồi thêm index, đo lại.
- Keyword: `EXPLAIN ANALYZE`, `Seq Scan`, `Index Scan`, `cost`, `actual time`, `CREATE INDEX`, `ANALYZE`.

## 4. Bẫy

- Plan không đổi sau khi thêm index là **kết quả hợp lệ** ở data nhỏ. Ghi lại lý do.
- Đừng ép bằng `SET enable_seqscan = off` trừ khi mục đích là học cách planner quyết định.
- `EXPLAIN ANALYZE` chạy query thật. Với `INSERT/UPDATE/DELETE` nó thực sự ghi, bọc trong `begin; ... rollback;`.

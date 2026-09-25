# 🗺️ Lộ trình Data Engineering → GenAI — Tracker (MVP Sprint)

> **Dự án xuyên suốt:** Olist → Postgres → dbt → (Airflow tối giản) → Semantic layer lite → Text-to-SQL Agent → FastAPI → UI React
> **Nhịp học:** 1 buổi / 2 ngày, ~1–1.5h/buổi, trong 1 tháng (~13 buổi CORE + 2 buổi STRETCH)
> **Ngày bắt đầu:** ____ / ____ / ______
> **Mục tiêu cuối:** 1 repo chạy được — hỏi tiếng Việt/Anh → ra SQL đúng → trả bảng kết quả, kèm pipeline DE thật phía sau (không phải demo giả).

**Trạng thái:** ⬜ Chưa làm · 🟨 Đang làm · ✅ Xong · ⏸️ Tạm dừng

> ⚠️ **So với bản gốc (13–17 tuần × 8–10h/tuần ≈ 100–170h), ngân sách ở đây chỉ ~15–22h.**
> Cắt: lý thuyết sâu, SCD Type 2, CDC/Kafka, Lakehouse, MetricFlow đầy đủ, eval Spider/BIRD, biểu đồ, streaming SSE.
> Giữ: đủ mỗi tầng để pipeline *thật* chạy được, và toàn bộ phần text-to-SQL (mục tiêu chính).
> Muốn học sâu hơn từng phần — làm tiếp ở mục **"Sau MVP"** cuối file, không chặn tiến độ tháng đầu.

---

## 📊 Tổng quan tiến độ (13 buổi CORE + 2 buổi STRETCH)

| # | Buổi | Nội dung | Trạng thái |
|---|---|---|---|
| 1 | S1 | Docker Postgres + ingest Olist vào `raw` | ⬜ |
| 2 | S2 | dbt staging | ⬜ |
| 3 | S3 | dbt marts — star schema tối giản | ⬜ |
| 4 | S4 | dbt tests + docs | ⬜ |
| 5 | S5 | SQL thực hành trên mart (10 query) | ⬜ |
| 6 | S6 | Semantic layer lite + eval set 20 câu | ⬜ |
| 7 | S7 | Text-to-SQL A1 — baseline full-schema prompt | ⬜ |
| 8 | S8 | Text-to-SQL A3 — agent tool-calling + self-correct | ⬜ |
| 9 | S9 | Guardrails (read-only, LIMIT, timeout, chặn DML) | ⬜ |
| 10 | S10 | FastAPI wrap agent | ⬜ |
| 11 | S11 | UI React tối giản | ⬜ |
| 12 | S12 | Orchestration tối giản (1 DAG/script) | ⬜ |
| 13 | S13 | End-to-end, đo accuracy, README, demo | ⬜ |
| 14 | S14* | Stretch: RAG (pgvector) hoặc SCD2 | ⬜ |
| 15 | S15* | Stretch: MetricFlow self-host hoặc Phase 3B mini | ⬜ |

\* S14–S15 chỉ làm nếu S1–S13 xong sớm hoặc còn buổi dư trong tháng.

---

## CORE — Tuần 1 (S1–S4): Data nền

### S1 — Ingest Olist vào Postgres · ⬜
- [ ] `docker-compose.yml`: Postgres + pgAdmin
- [ ] Script Python nạp CSV Olist vào schema `raw` (dùng `COPY` hoặc `pandas.to_sql`)
- [ ] Idempotent: `TRUNCATE` trước khi load lại (đủ dùng cho MVP, không cần incremental logic phức tạp)
- [ ] **Output:** `docker compose up` + `python ingest.py` chạy 1 lệnh ra data trong `raw`

### S2 — dbt staging · ⬜
- [ ] `dbt init`, cấu hình `profiles.yml` trỏ Postgres
- [ ] Model `stg_*` cho: orders, customers, order_items, products, sellers, reviews
- [ ] Dùng `source()` + `ref()` đúng chuẩn
- [ ] **Output:** `dbt run` xanh hết staging layer

### S3 — dbt marts (star schema tối giản) · ⬜
- [ ] `fact_orders`, `dim_customer`, `dim_product`, `dim_date` (bỏ `dim_seller` nếu thiếu giờ, thêm ở S14 nếu dư)
- [ ] SCD Type 1 only (ghi đè, không giữ lịch sử) — SCD2 để STRETCH
- [ ] **Output:** schema `marts` query được trực tiếp

### S4 — dbt tests + docs · ⬜
- [ ] Test `unique` + `not_null` trên khóa chính mọi bảng mart
- [ ] Test `relationships` cho khóa ngoại `fact_orders`
- [ ] `dbt docs generate` — cái này sẽ nuôi data dictionary ở S6
- [ ] **Output:** `dbt test` xanh hết, có `manifest.json` + `catalog.json`

---

## CORE — Tuần 2 (S5–S8): Semantic layer + Text-to-SQL lõi

### S5 — SQL thực hành trên mart · ⬜
- [ ] 10 query: window functions (`ROW_NUMBER`, `LAG/LEAD`), CTE, `EXISTS`/`NOT EXISTS`
- [ ] Viết trực tiếp trên `marts`, không phải bảng raw — vừa học vừa kiểm tra mart đúng
- [ ] **Output:** `sql/analysis/` — 10 file `.sql`, sẽ tái dùng làm eval set

### S6 — Semantic layer lite + eval set · ⬜
- [ ] `description` cho model + cột quan trọng trong `schema.yml` (chỉ mart, không toàn repo)
- [ ] Script Python nhỏ: đọc `manifest.json` + `information_schema` → dump `metadata/dictionary.json`
- [ ] Soạn **20 cặp Câu hỏi → SQL** (dùng lại 10 query ở S5 + viết thêm 10 câu tương tự bằng ngôn ngữ tự nhiên)
- [ ] **Output:** `metadata/dictionary.json`, `eval/golden_queries.yaml` (20 dòng)

> Bỏ MetricFlow/dbt Semantic Layer chính thức ở giai đoạn này — dictionary JSON tự chế là đủ cho agent đọc schema. Xem lý do chọn ở mục "Nguồn free thay thế" cuối file.

### S7 — Text-to-SQL A1: baseline · ⬜
- [ ] Prompt nhồi toàn bộ `dictionary.json` (schema + description) + câu hỏi user
- [ ] Gọi Claude API, sinh SQL, chạy thử, so kết quả với 20 câu eval
- [ ] Ghi accuracy baseline (execution accuracy: kết quả đúng, không chỉ SQL giống hệt)
- [ ] **Output:** script `eval_a1.py`, log accuracy đầu tiên

### S8 — Text-to-SQL A3: agent tool-calling · ⬜
- [ ] Bỏ qua A2 (RAG/pgvector) ở CORE — để STRETCH nếu accuracy A1 không đủ tốt hoặc còn giờ
- [ ] Tool: `list_tables`, `get_schema`, `run_query` (dùng `dictionary.json` làm nguồn schema, không cần vector search)
- [ ] Vòng tự sửa khi SQL lỗi, giới hạn 2 lần retry
- [ ] **Output:** agent (LangGraph hoặc tool-loop tự viết), so accuracy với A1

---

## CORE — Tuần 3 (S9–S12): Đưa ra sản phẩm chạy được

### S9 — Guardrails · ⬜
- [ ] DB role read-only, chỉ cấp quyền `SELECT` trên schema `marts`
- [ ] `LIMIT` mặc định (vd 100) nếu SQL sinh ra không có
- [ ] `statement_timeout` ở connection
- [ ] Regex chặn `INSERT/UPDATE/DELETE/ALTER/DROP/CREATE/TRUNCATE` trước khi execute (lớp phòng thủ thứ 2 ngoài role read-only)
- [ ] **Output:** agent an toàn kể cả khi LLM sinh SQL phá hoại

### S10 — FastAPI wrap · ⬜
- [ ] `POST /ask` → `{ sql, columns, rows, error }` (Pydantic schema)
- [ ] `GET /health`, CORS mở cho localhost UI
- [ ] **Output:** `uvicorn` chạy, test bằng `/docs` tự sinh

### S11 — UI React tối giản · ⬜
- [ ] Vite + React + TS, 1 trang: ô nhập câu hỏi, hiển thị SQL sinh ra, bảng kết quả
- [ ] Gọi API bằng `fetch` thường (bỏ TanStack Query, bỏ Recharts — thêm ở STRETCH nếu muốn)
- [ ] **Output:** demo hỏi–đáp chạy trên trình duyệt

### S12 — Orchestration tối giản · ⬜
- [ ] 1 Airflow DAG **hoặc** 1 script Python + cron (chọn cái nhanh hơn với thời gian còn lại): `ingest → dbt run → dbt test`
- [ ] Không cần retry/alert phức tạp ở MVP
- [ ] **Output:** 1 lệnh/1 lịch chạy lại được toàn bộ pipeline từ đầu

---

## CORE — S13: Chốt MVP

- [ ] Chạy lại toàn bộ pipeline từ đầu trên máy sạch, đo accuracy cuối trên 20 câu eval
- [ ] README: cách chạy (`docker compose up`, `dbt run`, `uvicorn`, `npm run dev`)
- [ ] Ghi lại số liệu accuracy A1 vs A3 vào bảng dưới
- [ ] **Output:** repo tự chạy được end-to-end từ máy mới clone

---

## STRETCH (chỉ làm nếu dư buổi trong tháng)

### S14 — chọn 1
- [ ] **RAG (A2):** embed `dictionary.json` + eval set vào pgvector, retrieve top-k bảng, so accuracy với A1/A3 — làm nếu accuracy A1 thấp
- [ ] **hoặc SCD Type 2:** thêm `dim_seller` + snapshot lịch sử thay đổi

### S15 — chọn 1
- [ ] **MetricFlow self-host (free, xem mục dưới):** định nghĩa 2–3 metric (vd `total_revenue`, `avg_order_value`), thử `dbt sl query`
- [ ] **hoặc Phase 3B mini:** LLM phân loại sentiment `order_reviews` → 1 cột mới trong mart, idempotent

---

## 🔁 Sau MVP (không giới hạn thời gian, làm khi rảnh)

Đây là phần đã cắt khỏi tháng đầu, giữ lại làm backlog:
- SQL nâng cao đầy đủ (30 query, `EXPLAIN ANALYZE`, index B-tree)
- Data modeling đầy đủ (3NF vs Dimensional, SCD2 toàn bộ dim)
- Ingestion incremental thật (không chỉ truncate-reload)
- CDC: Debezium + Kafka từ DB app Spring Boot
- Lakehouse: DuckDB + Parquet/Iceberg
- Eval mở rộng trên subset Spider 2.0 / BIRD
- Streaming từng bước agent qua SSE
- UI: biểu đồ Recharts, TanStack Query, lịch sử hội thoại
- Semantic layer chính thức (MetricFlow đầy đủ hoặc Cube)

---

## 📝 Nhật ký học tập

| Ngày | Buổi | Đã làm | Vướng mắc | Tiếp theo |
|---|---|---|---|---|
| | | | | |
| | | | | |

---

## 📈 Kết quả accuracy (điền ở S7, S8, và STRETCH nếu làm A2)

| Cách tiếp cận | Accuracy (/20) | Ghi chú |
|---|---|---|
| A1 — Baseline full-schema prompt | | |
| A3 — Agent tool-calling + self-correct | | |
| A2 — RAG (nếu làm STRETCH) | | |

---

## 🧠 Quyết định thiết kế (ADR ngắn)

| # | Quyết định | Lý do | Phương án đã loại |
|---|---|---|---|
| 1 | UI dùng React (Vite + TS), agent bọc bằng FastAPI | Đã có nền React; FastAPI cùng ngôn ngữ Python với agent; tách UI/API rõ ràng | Next.js (chưa quen, học tốn thời gian), Streamlit (khó tuỳ biến) |
| 2 | Semantic layer lite (JSON tự chế) thay vì MetricFlow/dbt Semantic Layer ở MVP | Ngân sách ~15-22h không đủ setup MetricFlow + học cú pháp metric; JSON dictionary đủ cho agent đọc schema | dbt Cloud Semantic Layer (trả phí, cần Team/Enterprise plan) |
| 3 | Bỏ Vanna AI khỏi dependency, chỉ tự xây agent (A1→A3) | Repo Vanna archived 3/2026, không còn maintain chính thức | Dùng Vanna làm base rồi fork sửa |

---

## 📚 Tài nguyên

| Loại | Tên | Link | Ghi chú |
|---|---|---|---|
| Dataset | Olist Brazilian E-Commerce | https://github.com/cmcouto-silva/olist-db | |
| Dataset | Chinook (dự phòng, nhẹ hơn) | https://github.com/lerocha/chinook-database | |
| Benchmark | Spider 2.0 | https://github.com/xlang-ai/Spider2 · https://spider2-sql.github.io/ | Backlog sau MVP |
| Benchmark | BIRD | https://bird-bench.github.io/ | Backlog sau MVP |
| Text-to-SQL OSS (tham khảo, KHÔNG phải dependency) | Dataherald | https://github.com/Dataherald/dataherald | Apache 2.0, còn maintain — coi kiến trúc agent, không cần cài |
| Text-to-SQL OSS (tham khảo) | Wren AI (OSS core) | https://github.com/Canner/WrenAI | Còn maintain 2026, mạnh về business metrics/joins — tham khảo kiến trúc |
| ~~Vanna AI~~ | ~~vanna-ai/vanna~~ | https://github.com/vanna-ai/vanna | ⚠️ Repo archived 3/2026, chỉ còn Vanna Cloud (trả phí). Không dùng làm dependency, chỉ đọc code cũ nếu muốn tham khảo. |
| Semantic layer free | MetricFlow (self-host, CLI) | https://github.com/dbt-labs/metricflow | Apache 2.0 từ 10/2025, chạy free local qua `dbt-metricflow`. dbt Cloud Semantic Layer (hosted, query qua API/BI) mới là phần trả phí — không cần cho MVP/STRETCH. |
| Agent mẫu | LangGraph SQL agent (docs chính thức) | https://docs.langchain.com/oss/python/langgraph/sql-agent | |
| Sách | The Data Warehouse Toolkit (Kimball) | — | Backlog sau MVP |
| Sách | Fundamentals of Data Engineering (Reis & Housley) | — | Backlog sau MVP |

---

## ✅ Nguyên tắc
1. Không sang Text-to-SQL khi mart còn bẩn: *garbage schema in → hallucinated SQL out*.
2. Mỗi buổi xong phải có commit + ghi 1 dòng vào Nhật ký học tập.
3. Luôn đo accuracy trước và sau mỗi thay đổi ở phần Text-to-SQL.
4. Hết giờ buổi học thì dừng, kể cả chưa xong checklist — ghi vào "Vướng mắc" rồi qua buổi sau, không cố kéo dài (nhịp 2 ngày/buổi không có dư sức để bù).

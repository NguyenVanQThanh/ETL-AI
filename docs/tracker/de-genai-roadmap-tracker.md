# 🗺️ Lộ trình Data Engineering → GenAI — Tracker

> **Dự án xuyên suốt:** Olist → Postgres → dbt → Airflow → Semantic layer → Text-to-SQL Agent → FastAPI → UI React → (Phase 2) CDC/Kafka + Lakehouse + Kubernetes
> **Nhịp học:** 1 buổi / 2 ngày, ~1–1.5h/buổi
> **Cấu trúc:** mỗi Phase = 1 tháng = ~15 buổi
> **Ngày bắt đầu Phase 1:** ____ / ____ / ______

**Trạng thái:** ⬜ Chưa làm · 🟨 Đang làm · ✅ Xong · ⏸️ Tạm dừng

---

## 🎯 Tổng quan 2 Phase

| Phase | Thời lượng | Trọng tâm | Mục tiêu cuối phase |
|---|---|---|---|
| **Phase 1** | Tháng 1 (~15 buổi) | Data nền + Text-to-SQL | Repo chạy được end-to-end: Postgres → dbt → agent hỏi-đáp → FastAPI → UI, đo được accuracy |
| **Phase 2** | Tháng 2 (~15 buổi) | Streaming thật (CDC/Kafka) + Lakehouse + Production deploy (Kubernetes) | Cùng hệ thống Phase 1 nhưng: ingest qua CDC/Kafka thay vì batch reload, orchestration đầy đủ, container hoá, deploy lên Kubernetes local (minikube/kind) |

Không cắt nội dung gốc — mọi phần trong roadmap ban đầu (SCD2, RAG, CDC, Kafka, Lakehouse, MetricFlow đầy đủ, eval Spider/BIRD, K8s) đều có mặt, chỉ chia lại theo 2 phase cho vừa nhịp học.

---

# 📘 PHASE 1 — Data nền + Text-to-SQL (Tháng 1, ~15 buổi)

## Tổng quan Phase 1

| # | Buổi | Nội dung | Trạng thái |
|---|---|---|---|
| 1 | P1.S1 | Docker Postgres + ingest Olist vào `raw` | ⬜ |
| 2 | P1.S2 | dbt staging | ⬜ |
| 3 | P1.S3 | dbt marts — star schema | ⬜ |
| 4 | P1.S4 | dbt tests + docs | ⬜ |
| 5 | P1.S5 | SQL thực hành trên mart (window functions, CTE...) | ⬜ |
| 6 | P1.S6 | Semantic layer + eval set 20 câu | ⬜ |
| 7 | P1.S7 | Text-to-SQL A1 — baseline full-schema prompt | ⬜ |
| 8 | P1.S8 | Text-to-SQL A2 — RAG (pgvector) retrieval schema | ⬜ |
| 9 | P1.S9 | Text-to-SQL A3 — agent tool-calling + self-correct | ⬜ |
| 10 | P1.S10 | Guardrails (read-only, LIMIT, timeout, chặn DML) | ⬜ |
| 11 | P1.S11 | FastAPI wrap agent | ⬜ |
| 12 | P1.S12 | UI React | ⬜ |
| 13 | P1.S13 | Orchestration — 1 Airflow DAG (ingest → dbt run → dbt test) | ⬜ |
| 14 | P1.S14 | SCD Type 2 cho `dim_seller` (snapshot lịch sử) | ⬜ |
| 15 | P1.S15 | End-to-end, đo accuracy, README, demo — chốt Phase 1 | ⬜ |

## Chi tiết Phase 1

### P1.S1 — Ingest Olist vào Postgres · ⬜
- [ ] `docker-compose.yml`: Postgres + pgAdmin
- [ ] Script Python nạp CSV Olist vào schema `raw` (`COPY` hoặc `pandas.to_sql`)
- [ ] Idempotent: `TRUNCATE` trước khi load lại
- [ ] **Output:** `docker compose up` + `python ingest.py` ra data trong `raw`

### P1.S2 — dbt staging · ⬜
- [ ] `dbt init`, `profiles.yml` trỏ Postgres
- [ ] Model `stg_*`: orders, customers, order_items, products, sellers, reviews
- [ ] Dùng `source()` + `ref()` đúng chuẩn
- [ ] **Output:** `dbt run` xanh hết staging layer

### P1.S3 — dbt marts (star schema) · ⬜
- [ ] `fact_orders`, `dim_customer`, `dim_product`, `dim_seller`, `dim_date`
- [ ] SCD Type 1 (ghi đè) ở bước này — SCD2 làm riêng ở P1.S14
- [ ] **Output:** schema `marts` query được trực tiếp

### P1.S4 — dbt tests + docs · ⬜
- [ ] Test `unique` + `not_null` trên khóa chính mọi bảng mart
- [ ] Test `relationships` cho khóa ngoại `fact_orders`
- [ ] `dbt docs generate` — nuôi data dictionary ở P1.S6
- [ ] **Output:** `dbt test` xanh hết, có `manifest.json` + `catalog.json`

### P1.S5 — SQL thực hành trên mart · ⬜
- [ ] 10 query: window functions (`ROW_NUMBER`, `LAG/LEAD`), CTE, `EXISTS`/`NOT EXISTS`
- [ ] `EXPLAIN ANALYZE` trên 2-3 query chậm nhất, thử thêm index
- [ ] **Output:** `sql/analysis/` — 10 file `.sql`, tái dùng làm eval set

### P1.S6 — Semantic layer + eval set · ⬜
- [ ] `description` cho model + cột quan trọng trong `schema.yml`
- [ ] Script đọc `manifest.json` + `information_schema` → `metadata/dictionary.json`
- [ ] Soạn **20 cặp Câu hỏi → SQL** (dùng lại 10 query P1.S5 + viết thêm 10 câu ngôn ngữ tự nhiên)
- [ ] **Output:** `metadata/dictionary.json`, `eval/golden_queries.yaml`

### P1.S7 — Text-to-SQL A1: baseline · ⬜
- [ ] Prompt nhồi toàn bộ `dictionary.json` + câu hỏi user
- [ ] Gọi Claude API, sinh SQL, chạy thử, so với 20 câu eval (execution accuracy)
- [ ] **Output:** `eval_a1.py`, log accuracy baseline

### P1.S8 — Text-to-SQL A2: RAG · ⬜
- [ ] pgvector extension, embed từng bảng/cột trong `dictionary.json`
- [ ] Retrieve top-k bảng liên quan theo câu hỏi thay vì nhồi toàn schema
- [ ] So accuracy + độ dài prompt (token) với A1
- [ ] **Output:** `eval_a2.py`, bảng so sánh A1 vs A2

### P1.S9 — Text-to-SQL A3: agent tool-calling · ⬜
- [ ] Tool: `list_tables`, `get_schema`, `run_query`
- [ ] Vòng tự sửa khi SQL lỗi, giới hạn 2 lần retry
- [ ] **Output:** agent (LangGraph hoặc tool-loop tự viết), so accuracy A1/A2/A3

### P1.S10 — Guardrails · ⬜
- [ ] DB role read-only, chỉ `SELECT` trên schema `marts`
- [ ] `LIMIT` mặc định (100) nếu SQL sinh ra không có
- [ ] `statement_timeout` ở connection
- [ ] Regex chặn `INSERT/UPDATE/DELETE/ALTER/DROP/CREATE/TRUNCATE` trước khi execute
- [ ] **Output:** agent an toàn kể cả khi LLM sinh SQL phá hoại

### P1.S11 — FastAPI wrap · ⬜
- [ ] `POST /ask` → `{ sql, columns, rows, error }`
- [ ] `GET /health`, CORS cho localhost UI
- [ ] **Output:** `uvicorn` chạy, test qua `/docs`

### P1.S12 — UI React · ⬜
- [ ] Vite + React + TS: ô nhập câu hỏi, hiển thị SQL sinh ra, bảng kết quả
- [ ] TanStack Query cho fetch/cache, loading/error state
- [ ] **Output:** demo hỏi-đáp chạy trên trình duyệt

### P1.S13 — Orchestration cơ bản · ⬜
- [ ] 1 Airflow DAG: `ingest → dbt run → dbt test`, chạy local (docker)
- [ ] Retry cơ bản (2 lần), không cần alerting phức tạp (để Phase 2)
- [ ] **Output:** DAG chạy lại được toàn bộ pipeline từ đầu, thấy trên Airflow UI

### P1.S14 — SCD Type 2 · ⬜
- [ ] `dim_seller`: thêm `valid_from`, `valid_to`, `is_current`
- [ ] dbt snapshot cho `dim_seller`
- [ ] **Output:** query lịch sử thay đổi seller theo thời gian đúng

### P1.S15 — Chốt Phase 1 · ⬜
- [ ] Chạy lại toàn bộ pipeline từ đầu trên máy sạch
- [ ] Đo accuracy cuối A1 vs A2 vs A3 trên 20 câu eval
- [ ] README: cách chạy toàn bộ (docker, dbt, airflow, uvicorn, npm)
- [ ] **Output:** repo Phase 1 tự chạy end-to-end từ máy mới clone

---

# 📗 PHASE 2 — Streaming thật + Lakehouse + Production Deploy (Tháng 2, ~15 buổi)

> Điều kiện vào Phase 2: Phase 1 phải chạy được end-to-end (P1.S15 ✅) trước khi bắt đầu.

## Tổng quan Phase 2

| # | Buổi | Nội dung | Trạng thái |
|---|---|---|---|
| 1 | P2.S1 | CDC là gì + setup Debezium trên DB nguồn | ⬜ |
| 2 | P2.S2 | Kafka (docker) — broker, topic, producer/consumer cơ bản | ⬜ |
| 3 | P2.S3 | Debezium → Kafka → consumer Python ghi vào `raw` (streaming ingestion) | ⬜ |
| 4 | P2.S4 | Lakehouse: DuckDB + Parquet, so sánh với Postgres-only | ⬜ |
| 5 | P2.S5 | Iceberg/Delta table format — đọc/viết cơ bản qua DuckDB | ⬜ |
| 6 | P2.S6 | dbt incremental models thật (không truncate-reload) | ⬜ |
| 7 | P2.S7 | Airflow nâng cấp: sensor chờ Kafka, retry + alert (email/Slack webhook) | ⬜ |
| 8 | P2.S8 | MetricFlow self-host đầy đủ — định nghĩa metrics, `dbt sl query` | ⬜ |
| 9 | P2.S9 | Mở rộng eval: subset Spider 2.0 hoặc BIRD, so với accuracy nội bộ | ⬜ |
| 10 | P2.S10 | Observability: structured logging + Prometheus/Grafana lite cho pipeline | ⬜ |
| 11 | P2.S11 | Container hoá: Dockerfile cho FastAPI, UI, agent | ⬜ |
| 12 | P2.S12 | Kubernetes cơ bản: minikube/kind, Pod/Service/Deployment | ⬜ |
| 13 | P2.S13 | Deploy toàn hệ thống lên K8s (Postgres/FastAPI/UI qua manifests hoặc Helm) | ⬜ |
| 14 | P2.S14 | CI/CD lite: GitHub Actions build + test + deploy vào cluster local | ⬜ |
| 15 | P2.S15 | Streaming UX (SSE cho agent) + Capstone demo + báo cáo tổng kết | ⬜ |

## Chi tiết Phase 2

### P2.S1 — CDC + Debezium · ⬜
- [ ] Khái niệm CDC (log-based vs query-based), vì sao thay batch reload
- [ ] Setup Debezium connector trên 1 bảng nguồn (dùng chính Postgres `raw` làm nguồn giả lập app DB)
- [ ] **Output:** Debezium bắt được INSERT/UPDATE/DELETE thành change events

### P2.S2 — Kafka cơ bản · ⬜
- [ ] `docker-compose` Kafka + Zookeeper/KRaft
- [ ] Tạo topic, producer/consumer console test tay
- [ ] **Output:** message gửi/nhận được qua Kafka local

### P2.S3 — Pipeline streaming ingestion · ⬜
- [ ] Debezium đẩy change events vào Kafka topic
- [ ] Consumer Python đọc topic, upsert vào `raw` (thay cho `ingest.py` truncate-reload ở Phase 1)
- [ ] **Output:** thay đổi ở DB nguồn phản ánh vào `raw` gần real-time

### P2.S4 — Lakehouse: DuckDB + Parquet · ⬜
- [ ] Export `marts` ra Parquet, query lại bằng DuckDB
- [ ] So sánh tốc độ/chi phí lưu trữ với Postgres cho phần dữ liệu lịch sử
- [ ] **Output:** 1 layer "cold storage" Parquet query được

### P2.S5 — Table format (Iceberg/Delta) · ⬜
- [ ] Tạo 1 Iceberg table qua DuckDB hoặc PyIceberg, ghi/đọc, xem time-travel cơ bản
- [ ] **Output:** hiểu và demo được schema evolution + time travel

### P2.S6 — dbt incremental thật · ⬜
- [ ] Chuyển `fact_orders` từ full-refresh sang `incremental` (dùng `is_incremental()`, unique_key)
- [ ] Xử lý late-arriving data cơ bản
- [ ] **Output:** `dbt run` chỉ xử lý dữ liệu mới, nhanh hơn rõ rệt

### P2.S7 — Airflow nâng cấp · ⬜
- [ ] Sensor chờ tín hiệu từ Kafka consumer (hoặc file marker) trước khi chạy dbt
- [ ] Retry với backoff, alert qua Slack webhook hoặc email khi fail
- [ ] **Output:** DAG chịu lỗi tốt hơn, có cảnh báo khi pipeline hỏng

### P2.S8 — MetricFlow self-host đầy đủ · ⬜
- [ ] Cài `dbt-metricflow`, định nghĩa 3-5 metric (`total_revenue`, `avg_order_value`, `order_count`...)
- [ ] `dbt sl query` lấy metric, so với cách viết SQL tay
- [ ] **Output:** semantic layer chính thức chạy local, free (Apache 2.0)

### P2.S9 — Eval mở rộng · ⬜
- [ ] Lấy subset nhỏ (10-20 câu phù hợp schema Olist) từ Spider 2.0 hoặc BIRD, hoặc tự soạn thêm câu khó (nested query, multi-join)
- [ ] Đo accuracy A3 trên set mới, so với set 20 câu nội bộ
- [ ] **Output:** hiểu rõ hơn giới hạn thật của agent so với benchmark chuẩn ngành

### P2.S10 — Observability · ⬜
- [ ] Structured logging (JSON) cho agent + API + pipeline
- [ ] Prometheus scrape metrics cơ bản (request count, latency, accuracy theo thời gian), Grafana dashboard tối giản
- [ ] **Output:** nhìn được sức khỏe hệ thống qua dashboard, không chỉ log tay

### P2.S11 — Container hoá · ⬜
- [ ] Dockerfile riêng cho FastAPI/agent, Dockerfile riêng cho UI (build production)
- [ ] `docker-compose` mới gộp toàn bộ Phase 1 + 2 (Postgres, Kafka, Airflow, FastAPI, UI)
- [ ] **Output:** `docker compose up` chạy toàn hệ thống

### P2.S12 — Kubernetes cơ bản · ⬜
- [ ] Cài minikube hoặc kind, học Pod/Deployment/Service/ConfigMap/Secret
- [ ] Deploy thử 1 service đơn giản (FastAPI) lên cluster local
- [ ] **Output:** hiểu vòng đời 1 Pod, xem log/exec vào Pod

### P2.S13 — Deploy toàn hệ thống lên K8s · ⬜
- [ ] Viết manifests (hoặc Helm chart) cho Postgres, FastAPI, UI (Kafka/Airflow có thể giữ ngoài cluster nếu thiếu giờ)
- [ ] Ingress hoặc port-forward để truy cập UI
- [ ] **Output:** hệ thống chạy trên K8s local, không chỉ docker-compose

### P2.S14 — CI/CD lite · ⬜
- [ ] GitHub Actions: chạy `dbt test` + eval accuracy khi có PR
- [ ] Build image + deploy vào cluster local khi merge (hoặc chỉ build+push nếu không có cluster remote)
- [ ] **Output:** merge code tự động kiểm tra chất lượng + build image

### P2.S15 — Capstone: Streaming UX + Tổng kết · ⬜
- [ ] SSE cho `/ask`: stream từng bước agent (đang tìm bảng → đang sinh SQL → đang chạy...) ra UI
- [ ] Demo end-to-end: đổi data nguồn → thấy CDC/Kafka cập nhật → hỏi agent → ra kết quả mới
- [ ] Viết báo cáo tổng kết: kiến trúc cuối, accuracy cuối, đánh đổi đã chọn (vd tại sao không dùng managed Kafka/K8s)
- [ ] **Output:** repo hoàn chỉnh Phase 1 + Phase 2, README + kiến trúc diagram, demo quay video/gif

---

## 📝 Nhật ký học tập

| Ngày | Phase.Buổi | Đã làm | Vướng mắc | Tiếp theo |
|---|---|---|---|---|
| | | | | |
| | | | | |

---

## 📈 Kết quả accuracy

| Cách tiếp cận | Accuracy (/20, Phase 1) | Accuracy (eval mở rộng, Phase 2) | Ghi chú |
|---|---|---|---|
| A1 — Baseline full-schema prompt | | | |
| A2 — RAG (pgvector) | | | |
| A3 — Agent tool-calling + self-correct | | | |

---

## 🧠 Quyết định thiết kế (ADR ngắn)

| # | Quyết định | Lý do | Phương án đã loại |
|---|---|---|---|
| 1 | UI dùng React (Vite + TS), agent bọc bằng FastAPI | Đã có nền React; FastAPI cùng ngôn ngữ Python với agent; tách UI/API rõ ràng | Next.js (chưa quen), Streamlit (khó tuỳ biến) |
| 2 | Semantic layer: JSON dictionary tự chế ở Phase 1, MetricFlow self-host đầy đủ ở Phase 2 | Phase 1 cần nhanh để đo text-to-SQL sớm; MetricFlow xứng đáng học riêng khi đã có nền vững | dbt Cloud Semantic Layer (hosted, trả phí — không dùng ở cả 2 phase) |
| 3 | Bỏ Vanna AI khỏi dependency, tự xây agent (A1→A2→A3) | Repo Vanna archived 3/2026, không còn maintain chính thức | Dùng Vanna làm base rồi fork sửa |
| 4 | Kubernetes local (minikube/kind) thay vì cloud K8s (EKS/GKE) | Học đúng cơ chế K8s mà không tốn tiền cloud; đủ cho mục tiêu học tập | Cloud managed K8s (tốn phí, không cần thiết cho portfolio project) |
| 5 | Kafka/Debezium tự host bằng docker thay vì managed (Confluent Cloud) | Free, học được vận hành thật; project không cần độ tin cậy production | Confluent Cloud / MSK (trả phí) |

---

## 📚 Tài nguyên

| Loại | Tên | Link | Ghi chú |
|---|---|---|---|
| Dataset | Olist Brazilian E-Commerce | https://github.com/cmcouto-silva/olist-db | |
| Dataset | Chinook (dự phòng, nhẹ hơn) | https://github.com/lerocha/chinook-database | |
| Benchmark | Spider 2.0 | https://github.com/xlang-ai/Spider2 · https://spider2-sql.github.io/ | Dùng ở P2.S9 |
| Benchmark | BIRD | https://bird-bench.github.io/ | Dùng ở P2.S9 |
| Text-to-SQL OSS (tham khảo kiến trúc) | Dataherald | https://github.com/Dataherald/dataherald | Apache 2.0, còn maintain |
| Text-to-SQL OSS (tham khảo kiến trúc) | Wren AI (OSS core) | https://github.com/Canner/WrenAI | Còn maintain 2026, mạnh về business metrics/joins |
| ~~Vanna AI~~ | ~~vanna-ai/vanna~~ | https://github.com/vanna-ai/vanna | ⚠️ Archived 3/2026, chỉ còn Vanna Cloud (trả phí). Không dùng làm dependency. |
| Semantic layer free | MetricFlow (self-host, CLI) | https://github.com/dbt-labs/metricflow | Apache 2.0 từ 10/2025, chạy free local qua `dbt-metricflow`. dbt Cloud Semantic Layer (hosted) mới trả phí. |
| Agent mẫu | LangGraph SQL agent (docs chính thức) | https://docs.langchain.com/oss/python/langgraph/sql-agent | |
| CDC | Debezium | https://debezium.io/documentation/ | |
| Streaming | Apache Kafka (docker quickstart) | https://kafka.apache.org/quickstart | |
| Lakehouse | DuckDB | https://duckdb.org/docs/ | |
| Table format | Apache Iceberg | https://iceberg.apache.org/ | |
| Orchestration | Apache Airflow | https://airflow.apache.org/docs/ | |
| K8s local | minikube | https://minikube.sigs.k8s.io/docs/ | |
| K8s local | kind | https://kind.sigs.k8s.io/ | |
| Observability | Prometheus + Grafana | https://prometheus.io/docs/ · https://grafana.com/docs/ | |
| Sách | The Data Warehouse Toolkit (Kimball) | — | |
| Sách | Fundamentals of Data Engineering (Reis & Housley) | — | |
| Sách | Designing Data-Intensive Applications (Kleppmann) | — | Nền tảng cho Phase 2 (CDC, streaming) |

---

## ✅ Nguyên tắc
1. Không sang Text-to-SQL (P1.S7+) khi mart còn bẩn: *garbage schema in → hallucinated SQL out*.
2. Không bắt đầu Phase 2 khi Phase 1 chưa chạy end-to-end (P1.S15 chưa ✅).
3. Mỗi buổi xong phải có commit + ghi 1 dòng vào Nhật ký học tập.
4. Luôn đo accuracy trước và sau mỗi thay đổi ở phần Text-to-SQL (A1/A2/A3, cả 2 phase).
5. Hết giờ buổi học thì dừng, kể cả chưa xong checklist — ghi vào "Vướng mắc" rồi qua buổi sau.

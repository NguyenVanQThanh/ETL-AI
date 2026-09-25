# 🗺️ Data Engineering → GenAI Roadmap — Tracker

> **End-to-end project:** Olist → Postgres → dbt → Airflow → Semantic layer → Text-to-SQL Agent → FastAPI → React UI → (Phase 2) CDC/Kafka + Lakehouse + Kubernetes
> **Cadence:** 1 session every 2 days, ~1–1.5h/session
> **Structure:** each Phase = 1 month = ~15 sessions
> **Phase 1 start date:** ____ / ____ / ______

**Status:** ⬜ Not started · 🟨 In progress · ✅ Done · ⏸️ Paused

---

## 🎯 Two-Phase Overview

| Phase | Duration | Focus | End-of-phase goal |
|---|---|---|---|
| **Phase 1** | Month 1 (~15 sessions) | Data foundation + Text-to-SQL | End-to-end repo: Postgres → dbt → Q&A agent → FastAPI → UI, with measured accuracy |
| **Phase 2** | Month 2 (~15 sessions) | Real streaming (CDC/Kafka) + Lakehouse + Production deploy (Kubernetes) | Same system as Phase 1, but: ingestion via CDC/Kafka instead of batch reload, full orchestration, containerized, deployed to local Kubernetes (minikube/kind) |

Nothing from the original scope is cut — every part of the initial roadmap (SCD2, RAG, CDC, Kafka, Lakehouse, full MetricFlow, Spider/BIRD eval, K8s) is included, just regrouped into 2 phases to fit the study cadence.

---

# 📘 PHASE 1 — Data Foundation + Text-to-SQL (Month 1, ~15 sessions)

## Phase 1 overview

| # | Session | Content | Status |
|---|---|---|---|
| 1 | P1.S1 | Docker Postgres + ingest Olist into `raw` | ⬜ |
| 2 | P1.S2 | dbt staging | ⬜ |
| 3 | P1.S3 | dbt marts — star schema | ⬜ |
| 4 | P1.S4 | dbt tests + docs | ⬜ |
| 5 | P1.S5 | SQL practice on marts (window functions, CTEs...) | ⬜ |
| 6 | P1.S6 | Semantic layer + 20-question eval set | ⬜ |
| 7 | P1.S7 | Text-to-SQL A1 — baseline full-schema prompt | ⬜ |
| 8 | P1.S8 | Text-to-SQL A2 — RAG (pgvector) schema retrieval | ⬜ |
| 9 | P1.S9 | Text-to-SQL A3 — tool-calling agent + self-correction | ⬜ |
| 10 | P1.S10 | Guardrails (read-only, LIMIT, timeout, block DML) | ⬜ |
| 11 | P1.S11 | FastAPI wraps the agent | ⬜ |
| 12 | P1.S12 | React UI | ⬜ |
| 13 | P1.S13 | Orchestration — 1 Airflow DAG (ingest → dbt run → dbt test) | ⬜ |
| 14 | P1.S14 | SCD Type 2 for `dim_seller` (history snapshot) | ⬜ |
| 15 | P1.S15 | End-to-end run, measure accuracy, README, demo — close Phase 1 | ⬜ |

## Phase 1 details

### P1.S1 — Ingest Olist into Postgres · ⬜
- [ ] `docker-compose.yml`: Postgres + pgAdmin
- [ ] Python script loads Olist CSVs into the `raw` schema (`COPY` or `pandas.to_sql`)
- [ ] Idempotent: `TRUNCATE` before reload
- [ ] **Output:** `docker compose up` + `python ingest.py` populates `raw`

### P1.S2 — dbt staging · ⬜
- [ ] `dbt init`, `profiles.yml` pointing at Postgres
- [ ] `stg_*` models: orders, customers, order_items, products, sellers, reviews
- [ ] Proper `source()` + `ref()` usage
- [ ] **Output:** `dbt run` green across the staging layer

### P1.S3 — dbt marts (star schema) · ⬜
- [ ] `fact_orders`, `dim_customer`, `dim_product`, `dim_seller`, `dim_date`
- [ ] SCD Type 1 (overwrite) at this stage — SCD2 is its own step in P1.S14
- [ ] **Output:** `marts` schema is directly queryable

### P1.S4 — dbt tests + docs · ⬜
- [ ] `unique` + `not_null` tests on every mart's primary key
- [ ] `relationships` test for `fact_orders` foreign keys
- [ ] `dbt docs generate` — feeds the data dictionary in P1.S6
- [ ] **Output:** `dbt test` all green, `manifest.json` + `catalog.json` produced

### P1.S5 — SQL practice on marts · ⬜
- [ ] 10 queries: window functions (`ROW_NUMBER`, `LAG/LEAD`), CTEs, `EXISTS`/`NOT EXISTS`
- [ ] `EXPLAIN ANALYZE` on the 2-3 slowest queries, try adding an index
- [ ] **Output:** `sql/analysis/` — 10 `.sql` files, reused as the eval set

### P1.S6 — Semantic layer + eval set · ⬜
- [ ] `description` for every important model + column in `schema.yml`
- [ ] Script reads `manifest.json` + `information_schema` → `metadata/dictionary.json`
- [ ] Write **20 Question → SQL pairs** (reuse the 10 queries from P1.S5 + write 10 more in natural language)
- [ ] **Output:** `metadata/dictionary.json`, `eval/golden_queries.yaml`

### P1.S7 — Text-to-SQL A1: baseline · ⬜
- [ ] Prompt with the full `dictionary.json` + the user's question
- [ ] Call the Claude API, generate SQL, run it, compare against the 20-question eval set (execution accuracy)
- [ ] **Output:** `eval_a1.py`, logged baseline accuracy

### P1.S8 — Text-to-SQL A2: RAG · ⬜
- [ ] pgvector extension, embed each table/column from `dictionary.json`
- [ ] Retrieve top-k relevant tables per question instead of stuffing the whole schema
- [ ] Compare accuracy + prompt token length against A1
- [ ] **Output:** `eval_a2.py`, A1 vs A2 comparison table

### P1.S9 — Text-to-SQL A3: tool-calling agent · ⬜
- [ ] Tools: `list_tables`, `get_schema`, `run_query`
- [ ] Self-correction loop on SQL errors, capped at 2 retries
- [ ] **Output:** agent (LangGraph or a hand-rolled tool loop), compare accuracy across A1/A2/A3

### P1.S10 — Guardrails · ⬜
- [ ] Read-only DB role, `SELECT`-only on the `marts` schema
- [ ] Default `LIMIT` (100) when the generated SQL doesn't have one
- [ ] `statement_timeout` on the connection
- [ ] Regex blocks `INSERT/UPDATE/DELETE/ALTER/DROP/CREATE/TRUNCATE` before execution
- [ ] **Output:** the agent stays safe even if the LLM generates destructive SQL

### P1.S11 — FastAPI wrapper · ⬜
- [ ] `POST /ask` → `{ sql, columns, rows, error }`
- [ ] `GET /health`, CORS for the local UI
- [ ] **Output:** `uvicorn` running, testable via `/docs`

### P1.S12 — React UI · ⬜
- [ ] Vite + React + TS: question input, generated SQL display, results table
- [ ] TanStack Query for fetch/cache, loading/error states
- [ ] **Output:** working Q&A demo in the browser

### P1.S13 — Basic orchestration · ⬜
- [ ] 1 Airflow DAG: `ingest → dbt run → dbt test`, running locally (docker)
- [ ] Basic retry (2x), no need for full alerting yet (that's Phase 2)
- [ ] **Output:** DAG can rerun the whole pipeline from scratch, visible in the Airflow UI

### P1.S14 — SCD Type 2 · ⬜
- [ ] `dim_seller`: add `valid_from`, `valid_to`, `is_current`
- [ ] dbt snapshot for `dim_seller`
- [ ] **Output:** correctly query a seller's history of changes over time

### P1.S15 — Close out Phase 1 · ⬜
- [ ] Rerun the entire pipeline from scratch on a clean machine
- [ ] Measure final accuracy for A1 vs A2 vs A3 on the 20-question eval set
- [ ] README: how to run everything (docker, dbt, airflow, uvicorn, npm)
- [ ] **Output:** Phase 1 repo runs end-to-end from a fresh clone

---

# 📗 PHASE 2 — Real Streaming + Lakehouse + Production Deploy (Month 2, ~15 sessions)

> Entry condition: Phase 1 must run end-to-end (P1.S15 ✅) before starting.

## Phase 2 overview

| # | Session | Content | Status |
|---|---|---|---|
| 1 | P2.S1 | What CDC is + set up Debezium on the source DB | ⬜ |
| 2 | P2.S2 | Kafka (docker) — broker, topics, basic producer/consumer | ⬜ |
| 3 | P2.S3 | Debezium → Kafka → Python consumer writes to `raw` (streaming ingestion) | ⬜ |
| 4 | P2.S4 | Lakehouse: DuckDB + Parquet, compare against Postgres-only | ⬜ |
| 5 | P2.S5 | Table format (Iceberg/Delta) — basic read/write via DuckDB | ⬜ |
| 6 | P2.S6 | Real dbt incremental models (no more truncate-reload) | ⬜ |
| 7 | P2.S7 | Airflow upgrade: sensor waiting on Kafka, retry + alert (email/Slack webhook) | ⬜ |
| 8 | P2.S8 | Full self-hosted MetricFlow — define metrics, `dbt sl query` | ⬜ |
| 9 | P2.S9 | Extended eval: Spider 2.0 or BIRD subset, compare against internal accuracy | ⬜ |
| 10 | P2.S10 | Observability: structured logging + lightweight Prometheus/Grafana for the pipeline | ⬜ |
| 11 | P2.S11 | Containerization: Dockerfiles for FastAPI, UI, agent | ⬜ |
| 12 | P2.S12 | Kubernetes basics: minikube/kind, Pod/Service/Deployment | ⬜ |
| 13 | P2.S13 | Deploy the whole system to K8s (Postgres/FastAPI/UI via manifests or Helm) | ⬜ |
| 14 | P2.S14 | Lightweight CI/CD: GitHub Actions build + test + deploy to the local cluster | ⬜ |
| 15 | P2.S15 | Streaming UX (SSE for the agent) + capstone demo + wrap-up report | ⬜ |

## Phase 2 details

### P2.S1 — CDC + Debezium · ⬜
- [ ] CDC concepts (log-based vs. query-based), why it replaces batch reload
- [ ] Set up a Debezium connector on one source table (use the existing Postgres `raw` as a stand-in for an app DB)
- [ ] **Output:** Debezium captures INSERT/UPDATE/DELETE as change events

### P2.S2 — Kafka basics · ⬜
- [ ] `docker-compose` Kafka + Zookeeper/KRaft
- [ ] Create a topic, test producer/consumer by hand from the console
- [ ] **Output:** messages sent/received through local Kafka

### P2.S3 — Streaming ingestion pipeline · ⬜
- [ ] Debezium pushes change events into a Kafka topic
- [ ] Python consumer reads the topic, upserts into `raw` (replacing Phase 1's truncate-reload `ingest.py`)
- [ ] **Output:** changes in the source DB reflect into `raw` near-real-time

### P2.S4 — Lakehouse: DuckDB + Parquet · ⬜
- [ ] Export `marts` to Parquet, query it back with DuckDB
- [ ] Compare speed/storage cost against Postgres for historical data
- [ ] **Output:** a queryable "cold storage" Parquet layer

### P2.S5 — Table format (Iceberg/Delta) · ⬜
- [ ] Create an Iceberg table via DuckDB or PyIceberg, read/write, try basic time-travel
- [ ] **Output:** understand and demo schema evolution + time travel

### P2.S6 — Real dbt incremental models · ⬜
- [ ] Convert `fact_orders` from full-refresh to `incremental` (using `is_incremental()`, unique_key)
- [ ] Handle late-arriving data at a basic level
- [ ] **Output:** `dbt run` only processes new data, visibly faster

### P2.S7 — Airflow upgrade · ⬜
- [ ] Sensor that waits on a signal from the Kafka consumer (or a file marker) before running dbt
- [ ] Retry with backoff, alert via Slack webhook or email on failure
- [ ] **Output:** DAG is more resilient, alerts when the pipeline breaks

### P2.S8 — Full self-hosted MetricFlow · ⬜
- [ ] Install `dbt-metricflow`, define 3-5 metrics (`total_revenue`, `avg_order_value`, `order_count`...)
- [ ] `dbt sl query` to pull metrics, compare against hand-written SQL
- [ ] **Output:** a proper semantic layer running locally, free (Apache 2.0)

### P2.S9 — Extended eval · ⬜
- [ ] Pull a small subset (10-20 questions fitting the Olist schema) from Spider 2.0 or BIRD, or author harder questions yourself (nested queries, multi-join)
- [ ] Measure A3's accuracy on the new set, compare against the internal 20-question set
- [ ] **Output:** clearer picture of the agent's real limits vs. an industry-standard benchmark

### P2.S10 — Observability · ⬜
- [ ] Structured (JSON) logging for the agent + API + pipeline
- [ ] Prometheus scraping basic metrics (request count, latency, accuracy over time), a minimal Grafana dashboard
- [ ] **Output:** system health visible on a dashboard, not just hand-read logs

### P2.S11 — Containerization · ⬜
- [ ] Separate Dockerfiles for FastAPI/agent and for the production UI build
- [ ] New `docker-compose` combining all of Phase 1 + 2 (Postgres, Kafka, Airflow, FastAPI, UI)
- [ ] **Output:** `docker compose up` runs the whole system

### P2.S12 — Kubernetes basics · ⬜
- [ ] Install minikube or kind, learn Pod/Deployment/Service/ConfigMap/Secret
- [ ] Deploy one simple service (FastAPI) to the local cluster
- [ ] **Output:** understand a Pod's lifecycle, view logs/exec into a Pod

### P2.S13 — Deploy the full system to K8s · ⬜
- [ ] Write manifests (or a Helm chart) for Postgres, FastAPI, UI (Kafka/Airflow can stay outside the cluster if time is short)
- [ ] Ingress or port-forward to reach the UI
- [ ] **Output:** the system runs on local K8s, not just docker-compose

### P2.S14 — Lightweight CI/CD · ⬜
- [ ] GitHub Actions: run `dbt test` + accuracy eval on every PR
- [ ] Build the image + deploy to the local cluster on merge (or just build+push if there's no remote cluster)
- [ ] **Output:** merges automatically get a quality check + image build

### P2.S15 — Capstone: Streaming UX + Wrap-up · ⬜
- [ ] SSE for `/ask`: stream each agent step (finding tables → generating SQL → running it...) to the UI
- [ ] End-to-end demo: change source data → see CDC/Kafka update it → ask the agent → get a fresh result
- [ ] Write a wrap-up report: final architecture, final accuracy, trade-offs made (e.g. why not managed Kafka/K8s)
- [ ] **Output:** complete Phase 1 + Phase 2 repo, README + architecture diagram, recorded demo (video/gif)

---

## 📝 Learning log

| Date | Phase.Session | Done | Blockers | Next |
|---|---|---|---|---|
| | | | | |
| | | | | |

---

## 📈 Accuracy results

| Approach | Accuracy (/20, Phase 1) | Accuracy (extended eval, Phase 2) | Notes |
|---|---|---|---|
| A1 — Baseline full-schema prompt | | | |
| A2 — RAG (pgvector) | | | |
| A3 — Tool-calling agent + self-correction | | | |

---

## 🧠 Design decisions (short ADRs)

| # | Decision | Rationale | Alternatives rejected |
|---|---|---|---|
| 1 | UI in React (Vite + TS), agent wrapped by FastAPI | Existing React background; FastAPI shares Python with the agent; clean UI/API separation | Next.js (unfamiliar), Streamlit (hard to customize) |
| 2 | Semantic layer: hand-rolled JSON dictionary in Phase 1, full self-hosted MetricFlow in Phase 2 | Phase 1 needs speed to measure text-to-SQL early; MetricFlow deserves its own focused session once the foundation is solid | dbt Cloud Semantic Layer (hosted, paid — used in neither phase) |
| 3 | Drop Vanna AI as a dependency, build the agent from scratch (A1→A2→A3) | Vanna's repo was archived 3/2026, no longer officially maintained | Fork Vanna as a base and patch it |
| 4 | Local Kubernetes (minikube/kind) instead of cloud K8s (EKS/GKE) | Learn the actual K8s mechanics without cloud cost; sufficient for a learning goal | Cloud-managed K8s (costs money, unnecessary for a portfolio project) |
| 5 | Self-hosted Kafka/Debezium via docker instead of managed (Confluent Cloud) | Free, teaches real operational mechanics; the project doesn't need production-grade reliability | Confluent Cloud / MSK (paid) |

---

## 📚 Resources

| Type | Name | Link | Notes |
|---|---|---|---|
| Dataset | Olist Brazilian E-Commerce | https://github.com/cmcouto-silva/olist-db | |
| Dataset | Chinook (lighter fallback) | https://github.com/lerocha/chinook-database | |
| Benchmark | Spider 2.0 | https://github.com/xlang-ai/Spider2 · https://spider2-sql.github.io/ | Used in P2.S9 |
| Benchmark | BIRD | https://bird-bench.github.io/ | Used in P2.S9 |
| Text-to-SQL OSS (architecture reference) | Dataherald | https://github.com/Dataherald/dataherald | Apache 2.0, actively maintained |
| Text-to-SQL OSS (architecture reference) | Wren AI (OSS core) | https://github.com/Canner/WrenAI | Actively maintained in 2026, strong on business metrics/joins |
| ~~Vanna AI~~ | ~~vanna-ai/vanna~~ | https://github.com/vanna-ai/vanna | ⚠️ Archived 3/2026, only Vanna Cloud remains (paid). Not used as a dependency. |
| Free semantic layer | MetricFlow (self-hosted CLI) | https://github.com/dbt-labs/metricflow | Apache 2.0 since 10/2025, runs free locally via `dbt-metricflow`. dbt Cloud's hosted Semantic Layer is the paid part. |
| Agent example | LangGraph SQL agent (official docs) | https://docs.langchain.com/oss/python/langgraph/sql-agent | |
| CDC | Debezium | https://debezium.io/documentation/ | |
| Streaming | Apache Kafka (docker quickstart) | https://kafka.apache.org/quickstart | |
| Lakehouse | DuckDB | https://duckdb.org/docs/ | |
| Table format | Apache Iceberg | https://iceberg.apache.org/ | |
| Orchestration | Apache Airflow | https://airflow.apache.org/docs/ | |
| Local K8s | minikube | https://minikube.sigs.k8s.io/docs/ | |
| Local K8s | kind | https://kind.sigs.k8s.io/ | |
| Observability | Prometheus + Grafana | https://prometheus.io/docs/ · https://grafana.com/docs/ | |
| Book | The Data Warehouse Toolkit (Kimball) | — | |
| Book | Fundamentals of Data Engineering (Reis & Housley) | — | |
| Book | Designing Data-Intensive Applications (Kleppmann) | — | Foundational for Phase 2 (CDC, streaming) |

---

## ✅ Principles
1. Don't move to Text-to-SQL (P1.S7+) while the marts are still dirty: *garbage schema in → hallucinated SQL out*.
2. Don't start Phase 2 until Phase 1 runs end-to-end (P1.S15 not yet ✅).
3. Commit after every session + log one line in the Learning log.
4. Always measure accuracy before and after every change to the Text-to-SQL part (A1/A2/A3, both phases).
5. Stop when the session's time is up, even mid-checklist — log it under "Blockers" and pick it up next session.

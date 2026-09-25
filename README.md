# ETL-AI — Data Engineering → GenAI

Dự án học + portfolio xuyên suốt: **Olist e-commerce data → Postgres → dbt → Airflow → Semantic layer → Text-to-SQL Agent → FastAPI → React UI**, chia 2 phase (mỗi phase ~1 tháng, ~15 buổi).

## Trạng thái hiện tại

Repo mới ở giai đoạn **lên plan** — chưa có code thật. Xem tiến độ và checklist chi tiết tại:

- **Tracker tổng:** [docs/tracker/de-genai-roadmap-tracker.md](docs/tracker/de-genai-roadmap-tracker.md) (bản EN: [de-genai-roadmap-tracker.en.md](docs/tracker/de-genai-roadmap-tracker.en.md))
- **Chi tiết từng buổi Phase 1:** [docs/tracker/phase-1/](docs/tracker/phase-1/) — mỗi buổi 1 file `P1.S<XX>-*.md` theo template [`_TEMPLATE.md`](docs/tracker/phase-1/_TEMPLATE.md) (Prerequisite → Tech → Keyword → Step-by-step → Output → Nhật ký). Phase 2 sẽ dùng lại đúng template này.

## Kiến trúc mục tiêu (Phase 1)

```
Olist CSV → Postgres (raw) → dbt (staging → marts, star schema)
                                     │
                          Text-to-SQL Agent (A1 baseline → A2 RAG/pgvector → A3 tool-calling)
                                     │
                              FastAPI (/ask, /health)
                                     │
                              React UI (Vite + TS)

Orchestration: 1 Airflow DAG (ingest → dbt run → dbt test)
```

Phase 2 nâng lên: CDC/Kafka streaming ingestion, Lakehouse (DuckDB/Iceberg), MetricFlow, observability, container hoá + deploy Kubernetes local. Chi tiết: mục Phase 2 trong tracker tổng.

## Cách chạy

Chưa có gì để chạy — mỗi buổi trong `docs/tracker/phase-1/` sẽ có mục "Output mong muốn" làm tiêu chí xong. Hướng dẫn chạy full stack (docker/dbt/airflow/uvicorn/npm) sẽ được viết ở buổi chốt Phase 1 ([P1.S15](docs/tracker/phase-1/P1.S15-chot-phase-1-end-to-end.md)) và cập nhật lại phần này.

## Cấu trúc repo

```
docs/tracker/          # roadmap + chi tiết từng buổi học
scripts/delegate/      # wrapper delegate LLM (Aider/DeepSeek, Gemini CLI, Codex CLI) — hạ tầng harness, không phải code project
.claude/               # Claude Code harness: rules, skills, agents, hooks
```

## Nguyên tắc học (xem đầy đủ ở tracker)

1. Không sang Text-to-SQL khi mart còn bẩn.
2. Không bắt đầu Phase 2 khi Phase 1 chưa chạy end-to-end.
3. Mỗi buổi xong → commit + ghi Nhật ký học tập.
4. Luôn đo accuracy trước/sau mỗi thay đổi ở Text-to-SQL.

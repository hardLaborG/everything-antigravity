---
name: clickhouse-io
description: |
Reviews and designs ClickHouse schemas, queries, and migrations for high-throughput OLAP.
parameters:
type: object
properties:
schema_or_query:
type: string
description: "SQL query, DDL definition, or migration script to inspect"
required:
- schema_or_query
---

# ClickHouse Performance & Schema Guardrails

Verify ClickHouse SQL against high-performance OLAP standards.

## 1. DDL & Engine Invariants
- **Engine Selection:** Use `MergeTree`, `ReplacingMergeTree` (for eventual deduplication), or `AggregatingMergeTree` (for rollups).
- **Partitioning:** MUST use coarse time buckets (`toYYYYMM(date)` or `toYYYYMMDD`). NEVER partition by high-cardinality keys (UUIDs, user IDs).
- **ORDER BY (Primary Key):** Order columns from lowest cardinality to highest cardinality for optimal sparse index compression.
- **Data Types:** Use `LowCardinality(String)` for strings with < 10,000 distinct values. Use `Date` / `DateTime64(3, 'UTC')`.

## 2. DML & Ingestion Rules
- **Batching:** Single-row INSERT statements are strictly FORBIDDEN. Ingest via batches (min 1,000 rows) or utilize buffer/async insert engines (`SETTINGS async_insert=1`).
- **Query Scans:** SELECT queries must prune partitions using explicit date/timestamp predicates. Avoid `SELECT *`.
- **FINAL Keyword:** Do not use `FINAL` in production query paths; handle deduplication via argMax or aggregate merges.
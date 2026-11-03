---
name: clickhouse-io
description: |
  Reviews, validates, and designs ClickHouse schemas, client configurations, and queries
  for high-throughput OLAP with strict Fail-Fast configuration invariants and zero SQL string assembly.
parameters:
  type: object
  properties:
    schema_or_query:
      type: string
      description: "SQL query, DDL definition, migration script, or client integration code to inspect"
  required:
    - schema_or_query
---

# ClickHouse Performance, Schema & Security Guardrails

Inspect ClickHouse DDL, client configuration, and data ingestion queries against strict Fail-Fast and zero-injection standards.

## 1. Fail-Fast Configuration & Data Structure Invariants (CRITICAL)

- **Fail-Fast Client Initialization:**
  - Client configurations (host, port, credentials, timeouts, compression, connection pool sizes) MUST validate fail-fast in the object constructor.
  - Missing environment variables, empty endpoints, or invalid numerical bounds (e.g., negative timeouts, zero batch size) must raise immediate errors at initialization, NEVER deferred to the first query.
- **Schema & DDL Non-Null Default:**
  - Columns MUST be non-nullable by default (`Type` instead of `Nullable(Type)`). `Nullable` columns incur an 8-bit mask overhead per row, disrupt vectorized SIMD execution, and violate Zero-Null domain invariants.
  - Reject `Nullable(...)` unless explicitly required by an immutable domain contract.
- **Partitioning Strategy:**
  - Partitions MUST use coarse time buckets (e.g., `toYYYYMM(event_date)` or `toYYYYMMDD(event_date)`).
  - High-cardinality keys (UUIDs, user IDs, device IDs) in `PARTITION BY` are STRICTLY FORBIDDEN (causes filesystem inode and metadata exhaustion).
- **ORDER BY (Sparse Index Sorting Key):**
  - Columns must be ordered strictly from **lowest cardinality to highest cardinality** for optimal primary index compression and granule pruning.
- **Data Types & Compression:**
  - Strings with low cardinality (< 10,000 distinct values) MUST use `LowCardinality(String)`.
  - Timestamps must use `DateTime64(3, 'UTC')` or `Date`.
  - Tables with historical data must define explicit `TTL` expressions.

## 2. SQL Assembly & Injection Security (CRITICAL - Instant Reject)

- **Zero String Assembly:**
  - ANY string concatenation (`+`), template literals (`` `...${val}...` ``), format strings (Python `f"..."`, Go `fmt.Sprintf`), or `.format()` used to build SQL queries is **UNCONDITIONALLY REJECTED**.
- **Mandatory Parameterized Builders:**
  - All queries must use typed parameterized query builders or native ClickHouse parameter placeholders (`{param_name: DataType}`).
  - Dynamic table names or column identifiers must be validated against a strict compile-time enum/allowlist before builder dispatch.
- **Inspection Rule:**
  - If dynamic string interpolation or concatenation is detected in any SQL statement (`SELECT`, `INSERT`, `ALTER`, `OPTIMIZE`), immediately output:
    `CLICKHOUSE-IO SECURITY: REJECT - Unparameterized SQL query construction detected.`

## 3. DML, Ingestion & Query Execution Rules

- **Batching Mandate:**
  - Single-row `INSERT` statements are strictly FORBIDDEN in production paths.
  - Ingestion must occur in batches (minimum 1,000 rows per batch) or through async insert settings (`SETTINGS async_insert=1, wait_for_async_insert=1`).
- **Partition Pruning & Selective Projection:**
  - `SELECT *` is strictly FORBIDDEN.
  - All `SELECT` queries must include explicit partition key filtering (date/timestamp range) to avoid full table scans across all parts.
- **Banned `FINAL` Modifier:**
  - Do NOT use the `FINAL` modifier in production OLAP query paths. Handle deduplication via `argMax` or `ReplacingMergeTree` views with aggregation.

## Output Format

- If any violation is detected:
  `CLICKHOUSE-IO: REJECT` followed by `file:line`, violation type, and remediation code with parameterized builder / fail-fast constructor.
- If compliant:
  `CLICKHOUSE-IO: PASS`

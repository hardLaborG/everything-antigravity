# ClickHouse I/O Audit & Invariant Enforcement

## Purpose
This skill provides automated, unyielding audits of ClickHouse database configurations, DDL definitions, client wrappers, and query construction logic. It enforces high-throughput OLAP standards, strict Fail-Fast guarantees, and zero-tolerance for SQL injection and unsafe string interpolation.

---

## 1. Fail-Fast Configuration & Data Structure Rules

### 1.1 Client & Connection Initialization
All ClickHouse connection configuration must validate fail-fast within the constructor or factory function before any network call or query execution.

- **Forbidden:** Deferring missing host/port/credentials detection to the first query execution.
- **Forbidden:** Falling back silently to insecure defaults (e.g., `default` user with empty password on `localhost:8123` in non-test code).
- **Mandatory Checks at Construction:**
  - `endpoint` or `hosts`: Non-empty string array, valid URI scheme and port range (`1..65535`).
  - `database`: Non-empty, alphanumeric + underscore only.
  - `credentials`: Non-empty username and secret provider (loaded from validated environment variables).
  - `timeouts`: Connect timeout, read timeout, write timeout strictly `> 0`.
  - `batchSize`: Integer strictly `>= 1000`.

#### Compliant TypeScript Example:
```typescript
export class ClickHouseConfig {
  readonly endpoint: string;
  readonly database: string;
  readonly timeoutMs: number;
  readonly batchSize: number;

  constructor(endpoint: string, database: string, timeoutMs: number, batchSize: number) {
    if (!endpoint || !endpoint.startsWith('http')) {
      throw new Error(`ClickHouseConfig: invalid endpoint "${endpoint}"`);
    }
    if (!database || !/^[a-zA-Z0-9_]+$/.test(database)) {
      throw new Error(`ClickHouseConfig: invalid database name "${database}"`);
    }
    if (timeoutMs <= 0 || timeoutMs > 300_000) {
      throw new Error(`ClickHouseConfig: timeoutMs must be within 1..300000 ms, got ${timeoutMs}`);
    }
    if (batchSize < 1000) {
      throw new Error(`ClickHouseConfig: batchSize must be >= 1000 for OLAP ingestion, got ${batchSize}`);
    }
    this.endpoint = endpoint;
    this.database = database;
    this.timeoutMs = timeoutMs;
    this.batchSize = batchSize;
  }
}
```

### 1.2 DDL & Data Structure Invariants
- **Non-Nullable by Default:** Columns MUST use primitive non-nullable types (`UInt64`, `String`, `Date32`, `DateTime64(3, 'UTC')`). `Nullable(...)` columns allocate a hidden byte per value, impede vectorization, and violate domain purity. Reject `Nullable(...)` unless required by external upstream schemas.
- **Partitioning Bounds:**
  - `PARTITION BY` must use coarse time granularities: `toYYYYMM(event_date)` or `toYYYYMMDD(event_date)`.
  - Reject `PARTITION BY` on high-cardinality values (`user_id`, `uuid`, `device_id`, `item_id`). More than 1,000 active partitions causes metadata bloat, excessive merges, and server memory exhaustion.
- **ORDER BY Cardinality Hierarchy:**
  - Primary sort keys in `ORDER BY` must be ordered from **lowest cardinality to highest cardinality**.
  - Example: `ORDER BY (tenant_id, status, event_type, created_at, id)`.
- **LowCardinality Strings:**
  - Strings with dictionary size under 10,000 distinct values must be typed `LowCardinality(String)`.

---

## 2. Zero String Assembly SQL Security Invariant

### 2.1 The Absolute Ban
Any assembly of ClickHouse SQL queries using string concatenation, template literals, format functions, or interpolation is strictly forbidden.

#### Unconditionally Banned Patterns:
```typescript
// ❌ REJECT: Template literal interpolation
const sql = `SELECT * FROM events WHERE tenant_id = '${tenantId}'`;

// ❌ REJECT: String concatenation
const sql = "SELECT count() FROM logs WHERE level = '" + level + "'";
```
```python
# ❌ REJECT: Python f-string
query = f"SELECT * FROM metrics WHERE metric_name = '{name}'"

# ❌ REJECT: Python format
query = "SELECT * FROM metrics WHERE metric_name = '{}'".format(name)
```
```go
// ❌ REJECT: Go fmt.Sprintf
query := fmt.Sprintf("SELECT * FROM events WHERE id = '%s'", id)
```

### 2.2 Mandatory Parameterized Query Builders
Queries must be constructed using parameterized builders or native ClickHouse parameter binding (`{param: DataType}`).

#### Compliant Patterns:
```typescript
// ClickHouse HTTP / Client Native Parameter Binding
const query = `
  SELECT 
    tenant_id,
    event_type,
    count() AS total
  FROM events
  WHERE event_date >= {start_date: Date}
    AND event_date <= {end_date: Date}
    AND tenant_id = {tenant_id: UUID}
  GROUP BY tenant_id, event_type
`;
const params = {
  start_date: '2026-01-01',
  end_date: '2026-01-31',
  tenant_id: tenantId
};
await clickhouseClient.query({ query, query_params: params });
```

---

## 3. High-Throughput OLAP Ingestion & Querying Rules

1. **No Single-Row INSERTs:**
   - Single-row `INSERT INTO ... VALUES (...)` is forbidden in production paths.
   - Use batch ingestion (min 1,000 rows or 50MB chunks) or async insert engine settings:
     `SETTINGS async_insert=1, wait_for_async_insert=1`.
2. **Selective Projection & Partition Pruning:**
   - `SELECT *` is rejected. Explicitly declare required columns.
   - Every `SELECT` on partitioned tables must filter on the partition column (e.g., `event_date`).
3. **No `FINAL` in High-Concurrency Reads:**
   - Avoid `SELECT ... FROM table FINAL`.
   - Leverage `argMax(value, version)` or aggregating views to resolve deduplication without blocking mutations.

---

## 4. Audit Execution & Verdicts

When evaluating code or schema:
1. Scan for string concatenation / formatting in all query construction sites.
2. Verify configuration classes and structs validate all input arguments eagerly (Fail-Fast).
3. Validate DDL engines, partition clauses, and ORDER BY index efficiency.

### Verdict Output:
If any rule is violated:
```
CLICKHOUSE-IO: REJECT
File: path/to/file.ts:42
Violation: Dynamic string interpolation in ClickHouse SQL statement.
Remediation:
  Replace string interpolation with ClickHouse typed parameter binding:
  const query = 'SELECT event_type FROM events WHERE tenant_id = {tenant_id: UUID}';
  client.query({ query, query_params: { tenant_id: id } });
```
If fully compliant:
```
CLICKHOUSE-IO: PASS
All ClickHouse configurations are Fail-Fast and all queries are strictly parameterized.
```

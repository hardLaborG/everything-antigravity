# clickhouse-io Skill

ClickHouse schema review, fail-fast configuration validation, and zero-injection query enforcement.

## Overview
ClickHouse is a columnar OLAP database optimized for vectorized execution over large batches. This skill ensures:
1. **Fail-Fast Configuration:** All connection structures and schema models fail immediately on invalid bounds, missing configs, or unvalidated credentials.
2. **Strict SQL Parameterization:** Absolute prohibition of string assembly (`+`, `f-strings`, `fmt.Sprintf`, template literals) in query generation.
3. **Engine & Query Invariants:** Coarse-grained partitioning, lowest-to-highest cardinality sorting keys, batching `>= 1,000` rows, and selective partition pruning.

## Invariant Checklist
- [ ] Are all ClickHouse configurations initialized with eager validation (fail-fast)?
- [ ] Are all queries strictly parameterized via native `{param: Type}` or typed builders?
- [ ] Are string interpolations (`+`, `${...}`, `f"..."`, `fmt.Sprintf`) 100% eliminated?
- [ ] Are partition keys coarse time buckets (`toYYYYMM`, `toYYYYMMDD`)?
- [ ] Is `ORDER BY` ordered from lowest cardinality to highest cardinality?
- [ ] Are strings with < 10,000 distinct values typed as `LowCardinality(String)`?
- [ ] Is `SELECT *` eliminated in favor of explicit column lists?
- [ ] Are single-row inserts blocked in favor of batched or async inserts?

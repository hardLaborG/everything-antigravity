---
name: test-coverage
description: |
  Audits test coverage across codebase, identifies untested logic paths,
  and reports branch and line coverage metrics.
parameters:
  type: object
  properties:
    target_package:
      type: string
      description: "Specific package or module to analyze (optional)"
---

# Test Coverage Gatekeeper

Analyze test coverage and enforce high determinism.

## 1. Execution Protocol
Detect language and run coverage instrumentation:
- **Go:** `go test -coverprofile=coverage.out -covermode=atomic ./... && go tool cover -func=coverage.out`
- **Python:** `pytest --cov=. --cov-report=term-missing`
- **Rust:** `cargo tarpaulin --out Stdout`

## 2. Hard Invariants
- Minimum acceptable line coverage is **80%** (100% for financial logic, crypto, and authentication).
- For every uncovered code branch identified:
    1. Do NOT write complex mocks.
    2. Implement a focused test exercising the uncovered edge condition.
    3. Verify mutation resilience: ensuring test fails if branch condition is reversed.

## 3. Output
Produce a concise coverage summary:
- Total statement coverage percentage.
- Uncovered functions/methods with exact file and line numbers.
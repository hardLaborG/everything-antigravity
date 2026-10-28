---
name: dead-code-clean
description: |
  Identifies and safely purges unused functions, dead structs, and uncalled private methods.
---

# Dead Code Purge Protocol

Detect and remove unreachable or orphaned code without breaking contracts.

## 1. Detection
Run static analysis for dead code:
- **Go:** `deadcode ./...`
- **Python:** `vulture .`
- **Rust:** `cargo clippy -- -D dead_code`

## 2. Safety Invariants (Zero Breakage)
Before deleting any dead entity:
1. Verify it is not part of an exposed public interface or RPC contract.
2. Run entire test suite to ensure green baseline.
3. Remove dead code in an atomic step (`<= 100` lines diff).
4. Re-run test suite. If any test fails, rollback immediately.

## Output
Emit deleted symbol names and verify zero compiler warnings remaining.
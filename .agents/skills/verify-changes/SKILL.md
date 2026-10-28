---
name: verify-changes
description: |
  Performs pre-commit automated checks: line diff budget (<= 100 lines),
  linter errors, and unit test suite execution.
---

# Automated Verification Gatekeeper

Run all steps in order. If any step fails, ABORT execution and report the error.

## Step 1: Check Commit Diff Budget (Hard Invariant)
Run:
```bash
git diff --cached --stat | tail -n 1

```

* Parse additions and deletions.
* If `(insertions + deletions) > 100`:
* **FAIL IMMEDIATELY.**
* Message: `REJECT: Diff exceeds 100 modified lines limit. Decompose task or unstage files.`



## Step 2: Static Analysis & Linters

Detect environment and run the appropriate linter:

* **Go:** `golangci-lint run ./...`
* **Python:** `ruff check . && ruff format --check . && mypy .`
* **Rust:** `cargo clippy --all-targets -- -D warnings`

If any linter returns an exit code other than `0`:

* **FAIL IMMEDIATELY.** Suppressing linter warnings via inline comments is strictly forbidden.

## Step 3: Test Suite Execution

Run tests covering modified packages:

* **Go:** `go test -v -race ./...`
* **Python:** `pytest -v`
* **Rust:** `cargo test`

All tests must pass in milliseconds without timeouts.

## Verdict

If all 3 steps pass cleanly, output:
`VERIFICATION PASSED: Diff <= 100 lines, 0 linter errors, tests green.`

```
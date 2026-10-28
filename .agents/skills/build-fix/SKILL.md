---
name: build-fix
description: |
  Incrementally resolves compiler, type, and build errors one by one.
  Guarantees zero side-effect refactoring while fixing broken builds.
---

# Atomic Build Error Resolver

Fix build issues incrementally. Never attempt to fix multiple disconnected errors at once.

## Workflow

1. **Capture Failure:**
    - Run project build (`go build ./...`, `cargo check`, `mypy .`).
    - Isolate the FIRST error in compiler output. Ignore downstream cascade errors.
2. **Localize & Reason:**
    - Inspect the broken file around the offending line.
    - Formulate the smallest syntactic or type-compatible correction.
3. **Apply & Verify:**
    - Apply fix exclusively to the broken line/expression.
    - Do NOT perform unsolicited refactoring or stylistic edits.
    - Re-run build command.
4. **Invariant Check:**
    - If the fix introduces NEW errors or persists after 2 attempts, revert changes immediately and stop.
    - Confirm modified diff is `<= 20` lines.
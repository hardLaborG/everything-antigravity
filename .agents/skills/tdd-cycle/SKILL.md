---
name: tdd-cycle
description: |
  Enforces Bugayenko's two-step TDD cycle: creates a failing test first,
  commits it separately, then produces minimal implementation to pass.
parameters:
  type: object
  properties:
    issue_id:
      type: string
      description: "Target GitHub issue number (e.g., '42')"
    description:
      type: string
      description: "Brief summary of the feature or bug to test"
  required:
    - issue_id
    - description
---

# TDD Execution Cycle (Two-Step Protocol)

Execute these steps in strict sequence. Never skip steps or combine commits.

## Phase 1: Failing Test (Proof of Defect/Requirement)

1. **Write Test First:**
    - Create or update the unit test verifying the requirement.
    - Follow Angry Tests: one assertion, assertion at the end, clear negative failure message.
    - Do NOT touch production code yet.
2. **Execute Test:**
    - Run the test suite (`go test -v ./...` or `pytest`).
    - Confirm the new test fails for the expected reason (deterministic failure).
    - If CI breaks on the branch, add a temporary skip/ignore annotation with `@todo #{issue_id}: pending implementation`.
3. **Budget Check & Commit Step 1:**
    - Verify `git diff --cached --stat` has `<= 100` modified lines.
    - Stage ONLY test files.
    - Commit: `test(#{issue_id}): add reproducing test for {description}`.

## Phase 2: Minimal Implementation (Pass Only)

1. **Implement Fix:**
    - Remove any temporary skip annotation from the test.
    - Write the absolute minimum viable production code to satisfy the test.
    - Do NOT add speculative methods, helpers, or extra fields.
2. **Execute Verification:**
    - Re-run test suite. Confirm all tests pass.
    - Run project linters (`golangci-lint run` or `ruff check .`). Zero warnings permitted.
3. **Budget Check & Commit Step 2:**
    - Verify `git diff --cached --stat` has `<= 100` modified lines.
    - Stage ONLY production code files (and the test skip removal).
    - Commit: `feat(#{issue_id}): implement minimal logic to pass {description}`.
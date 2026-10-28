# Rule: Git Workflow and Atomic Increments

## Hard Invariants
1. **Commit Line Budget (Strict):** Total modified lines (`insertions + deletions`) in a single commit MUST be `<= 100`. Lockfiles and vendor code are exempt only if explicitly matched by `.gitignore`.
2. **Zero Bundling:** NEVER group unrelated changes, multiple bug fixes, or multiple features into one commit. One ticket/issue = one isolated change.
3. **No Squashing:** NEVER squash commits. Commit history must document the step-by-step evolution of thought.
4. **No Direct Commits to Default Branch:** All work must happen on dedicated task branches named strictly after the GitHub issue number (e.g., `42-auth-guard`).

---

## Two-Step Commit Protocol (MANDATORY)
Every functional task or bug fix MUST be delivered via at least two sequential commits:

### Step 1: Proof Commit (Test Only)
- Scope: Add or modify test files ONLY.
- Content: A failing unit test reproducing the exact defect or proving the contract requirement.
- CI Safety: If the failing test prevents repo-wide CI execution, disable/ignore it (`t.Skip()`, `pytest.mark.skip`, `@Ignore`) and add an `@todo #<issue_id>` puzzle comment above it.
- Invariant: Zero production code changes in this commit.

### Step 2: Implementation Commit (Fix Only)
- Scope: Remove the skip/ignore marker and implement the minimal production code to make the test pass.
- Invariant: Do not alter test expectations or assertions. Test code changes are forbidden in this step, except removing the skip annotation.

---

## Conventional Commits
- Subject: `<type>(#<issue_id>): <imperative verb> <concise summary>`
    - Examples: `test(#14): add failing test for nil token dereference`, `fix(#14): validate request token against nil`
- No emoji, no AI banners, no `Co-authored-by` footers.
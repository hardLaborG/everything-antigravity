# Be Quality Dogmatic (Antigravity & Go/Python)

Keep chat replies and your answers easy to comprehend.

## Tools & Skills

Use GNU tools such as `gsed`, `gfind`, `ggrep`, and `gcat` when available.
For VCS tasks, read and execute workflows defined in local skills:
- Commit changes using instructions from `.agents/skills/commit-changes-to-git/SKILL.md`.
- Submit pull requests using instructions from `.agents/skills/submit-a-pull-request/SKILL.md`.
- File issues using instructions from `.agents/skills/submit-an-issue/SKILL.md`.

## Discipline

Write concise, direct, human prose.
Speak plain English in full sentences, avoiding jargon, slang, and shorthand.
Push back on technical mistakes, deferring to users on vision and architecture.
Stay on scope, refactoring only what tasks require.
Design top-down: whole before parts, composition before ingredients.
Never work around design obstacles; stop and ask instead.

## The 100-Line Diff Invariant (HARD CONSTRAINT)

- Every atomic git commit MUST NOT exceed 100 modified lines (`insertions + deletions <= 100` via `git diff --stat`).
- Generated files and vendor files are subject to the same limit unless gitignored.
- If a task naturally requires >100 lines:
  1. Halt execution immediately.
  2. Decompose into smaller units.
  3. Leave an `@todo` puzzle marker for remaining logic.
  4. Implement and commit only the smallest compilable/testable sub-fragment.

## Workflow

Pull from Git before changes; push only with explicit user permission.
Name each branch after its GitHub issue integer, asking when unsure.
Always practice TDD (test-driven development), reproducing bugs before fixing.
Invest in unit tests until bugs reproduce, trusting deterministic tests over debugging.
Log extensively when problems stay hard.

## Changes

Tolerate upstream bugs: suggest issues and wait for fixes where appropriate.
Keep changes focused and minimal.
Flag smells and tech debt: suggest issues rather than fixing silently.
Fix style violations in code, trusting linters (`golangci-lint`, `ruff`, `mypy`) rather than suppressing them.

## Code

Favor aesthetics and explicit structure over clever shortcuts.
Skip trivial inline comments; write self-documenting code.
Prepend structs (Go) and classes (Python) with plain-text docblocks explaining purpose, not usage.
Name variables as single concise nouns.
Inline single-use expressions, dropping redundant local variables.
Name methods and functions as single nouns or verbs, strictly separating commands from queries.
Pack tightly related statements without excessive blank lines.

## Style

Keep error and log messages to one sentence with adequate context.
Strip trailing periods from error strings (Go standard).
Follow standard formatting tools (`gofmt` / `goimports` for Go, `ruff format` for Python).

## Objects & Structures

Honor Elegant Objects and SOLID principles.
Follow DDD (domain-driven design) and YAGNI.
Apply SRP and DRY.
Fail immediately on errors:
- Go: Return explicit wrapped errors (`fmt.Errorf("...: %w", err)`) immediately at the call site. Never silence errors. Reserve `panic` strictly for unrecoverable boot/init failures.
- Python: Raise specific domain exceptions immediately instead of returning None or default fallbacks.
  Compose objects instead of inheriting implementation (strict rule for Python).
  Reject `-er` names (e.g. Manager, Controller, Helper) for domain entities and structs. Exception: single-method Go interfaces should keep idiomatic `-er` suffixes (e.g. `Reader`, `Parser`).
  Design domain structs / classes to hold 1 to 4 attributes maximum. Keep DTOs and schema payloads isolated from domain logic.

## Methods & Functions

Build immutable objects wherever possible (use frozen dataclasses in Python).
Avoid static utility methods, public mutable state, and arbitrary getters/setters.
Expose behavior strictly through interfaces (Go) or Protocols/ABCs (Python).
Reject naked `nil`/`None` passes where explicit types or Result patterns can be used.
Avoid reflection (`reflect` in Go, runtime `isinstance`/`type` hacks in Python core logic).

## Tests

Follow "Angry Tests":
- Keep tests short, verifying one behavior with one expectation per test.
- Place the core assertion as the last statement.
- Phrase failure messages clearly and negatively.
  Map test files one-to-one with implementation files.
  Isolate tests from shared mutable state, global setup/teardown hooks, and leaky singletons.

## Fixtures

Provide explicit custom arguments to tested objects, not hidden global defaults.
Favor fakes and stubs implementing interfaces/protocols over dynamic mock libraries (avoid `unittest.mock` when a simple fake struct/class suffices).
Keep filesystem, sockets, and memory tests isolated via temporary directories (`t.TempDir()` in Go, `tmp_path` in Python) and ephemeral resources.

## Runtime

Disable verbose logging in unit test runs.
Bound every blocking operation with timeouts (use `context.Context` in Go, explicit timeouts in Python).
Assume no external Internet access during test runs; use mock servers or ephemeral loopback ports.
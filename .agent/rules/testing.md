# Rule: Testing Dogmas, TDD, and Mutation Verification

## TDD Enforcement
1. **Tests Precede Implementation:** Writing production code before a reproducing/specifying test is strictly forbidden.
2. **Strict Step Separation:** Never commit tests and implementation in the same atomic commit. Silencing an indicator while changing code hides defects.
3. **Determinism:** Tests MUST NOT rely on real network sockets, system clocks, sleep calls, or uncontrolled random states.

---

## Angry Tests Standard
Every unit test MUST adhere to the following structure:
- **Single Assertion:** One logical invariant per test method. Never write multi-step assertion chains.
- **Assertion Last:** The core expectation MUST always be the final statement of the test.
- **Negative Clarity:** Assertion failure messages must clearly articulate what contract broke and what invariant was violated.
- **No Test Inheritance:** Tests must not extend base test classes. Shared behavior must be injected via simple composition or helper functions.

---

## Fakes Over Mocks
- **Ban on Mocking Frameworks:** Forbid heavy runtime mocking libraries (`unittest.mock`, complex mock generators).
- **Interface Fakes:** If a dependency must be stubbed, implement a minimal fake object adhering to the domain interface.
- **Isolation:** File system interactions must be isolated using ephemeral temporary directories (`t.TempDir()`, `tmp_path`).

---

## Mutation Testing Mentality
- A test is worthless if it passes unconditionally on mutated logic.
- When writing a unit test, verify its strength: if an operator is inverted (`+` to `-`, `==` to `!=`) or a boundary is shifted, the test MUST fail (kill the mutant).
---
name: fe-test-coverage
description: |
  Enforces Vitest test quality gates for Vue 3 and TypeScript applications.
  Requires a Test-First pipeline before refactoring critical user flows (e.g. ProjectDetailView, client API),
  mandates public behavior black-box testing, and strictly bans global module mocks (vi.mock) in favor of EO Fakes.
parameters:
  type: object
  properties:
    target_component:
      type: string
      description: "Path to Vue component or TypeScript domain class to verify test coverage for"
  required:
    - target_component
---

# Frontend Test Coverage & Quality Gatekeeper (Vitest)

Audit and enforce strict test-driven development, black-box behavioral verification, and zero module-mocking policies across Vue 3 and TypeScript projects.

## 1. Test-First Gatekeeper Pipeline (CRITICAL)
- **Refactoring Blocker:**
  - ANY modification, feature addition, or refactoring targeting critical user flows (e.g., tender matrix decisions, file uploads, specification management in `ProjectDetailView.vue` and API clients) is **STRICTLY BLOCKED** until comprehensive unit and integration tests already exist and pass.
  - If a pull request or changeset modifies domain/UI logic without a pre-existing or accompanying test asserting the exact flow, declare:
    `FE-TEST-COVERAGE: REJECT - Missing behavioral test for critical user flow.`

## 2. Behavioral Testing (Black-Box Testing Invariant)
- **Public Behavior Verification:**
  - Tests must assert **observable behavior** (rendered DOM text, emitted domain events, returned values, HTTP contract fulfillment).
- **Prohibited State Probing:**
  - Direct assertions on internal reactive state properties (e.g. `expect(wrapper.vm.internalState).toBe(...)` or poking private object fields) are **STRICTLY FORBIDDEN**.
  - Test the object/component as a black box through its public interface or user actions (`fireEvent.click`, `wrapper.find(...).trigger('click')`).

## 3. Ban Global Module Mocks (No `vi.mock` Hijacking)
- **Banned Practice:**
  - `vi.mock('axios')`, `vi.mock('@/api/client')`, or monkey-patching module imports using `vi.mock(...)` is **UNCONDITIONALLY BANNED**.
- **Elegant Objects Mandate:**
  - Tests must use **Fake implementations** or **Null-Object stubs** that implement the real domain interface:
    - Instead of `vi.mock('s3')`, inject `new FakeS3Bucket()`.
    - Instead of mocking `RfqMatrix`, inject `new FakeRfqMatrix([itemA, itemB])`.
    - Instead of mocking auth headers, inject `new FakeTokenSupplier('test-token')`.

## 4. Assertion Protocol (Angry Tests)
- Each test must verify exactly **one logical assertion**.
- The assertion must be the **final statement** in the test block.
- Tests must produce unambiguous failure messages describing domain invariant violations.

## 5. Execution & Verification Commands

### Linux / macOS (Bash)
```bash
# Run Vitest with coverage for target component
npx vitest run src/views/__tests__/ProjectDetailView.spec.ts --coverage

# Ensure 100% test pass with zero skipped tests
npx vitest run --run
```

### Windows (PowerShell)
```powershell
# Run Vitest with coverage for target component
npx vitest run src/views/__tests__/ProjectDetailView.spec.ts --coverage

# Ensure 100% test pass with zero skipped tests
npx vitest run --run
```

## Output Format
If tests are missing, fail, or utilize banned `vi.mock` methods:
`FE-TEST-COVERAGE: REJECT` followed by file:line, violation reason, and replacement Fake pattern.

If all tests adhere to behavioral EO standards:
`FE-TEST-COVERAGE: PASS`

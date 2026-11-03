# Vitest Quality Gatekeeper & Test-First Protocol

## Purpose
This skill governs the testing methodology for Vue 3 and TypeScript applications (such as the `stroyka` project). It enforces a strict "Test-First" pipeline, mandates black-box behavioral verification, and eliminates brittle monkey-patching via `vi.mock`.

---

## 1. Test-First Pipeline Protocol

### The Gatekeeper Rule
No production code or refactoring in critical flows (e.g., `ProjectDetailView.vue`, API classes, tender decision logic, specification manipulation) may be committed or merged without prior or simultaneous tests covering the user workflow.

### Verification Steps:
1. **Detect Changes:** Inspect diff for modifications to business logic or UI templates.
2. **Locate Test Companion:** Ensure a corresponding `.spec.ts` or `.test.ts` exists under `__tests__/` or alongside the file.
3. **Verify Pre-Condition:** If changing existing behavior, verify a test captures the expected outcome before changing production code.

---

## 2. Behavioral Testing vs. State Probing

Tests must treat components and domain objects as **black boxes**:
- **Allowed:** Simulating user events (`click`, `input`), asserting on rendered DOM text/elements, asserting on returned domain values, asserting on calls to injected fake interfaces.
- **Banned:** Asserting directly on internal reactive properties or private instance variables.

### Anti-Pattern:
```typescript
// ❌ REJECT: Poking internal reactive state directly
test('updates count', async () => {
  const wrapper = mount(ProjectDetailView);
  expect((wrapper.vm as any).selectedCount).toBe(0); // Peeking internal state!
  (wrapper.vm as any).selectedCount = 2;              // Mutating internal state!
});
```

### Compliant Pattern:
```typescript
// ✅ APPROVED: Black-box interaction testing
test('displays updated selected count when user selects specification item', async () => {
  const fakeMatrix = new FakeRfqMatrix([new SpecificationItem('1', 'Cement', 'Materials', 100, 10)]);
  const wrapper = mount(ProjectDetailView, {
    props: { matrix: fakeMatrix }
  });

  await wrapper.find('[data-testid="item-checkbox-1"]').trigger('click');

  expect(wrapper.find('[data-testid="selected-summary"]').text()).toContain('Selected: 1');
});
```

---

## 3. Ban on Global Module Mocks (`vi.mock`)

### Why `vi.mock` is Banned:
1. It creates invisible global coupling.
2. It circumvents TypeScript's type system and fails silently when refactoring function signatures.
3. It bypasses object-oriented contracts.

### Anti-Pattern:
```typescript
// ❌ REJECT: Global module mock monkey-patching
import { vi, test, expect } from 'vitest';
vi.mock('@/api/client', () => ({
  fetchProjectDetails: vi.fn().mockResolvedValue({ id: '123', name: 'Tower A' })
}));
```

### Compliant Pattern (Elegant Objects Fakes):
Create an explicit fake class implementing the domain interface and pass it through constructor / prop injection:

```typescript
// ✅ APPROVED: Domain Interface and In-Memory Fake
export interface ProjectRegistry {
  getProject(id: string): Promise<Project>;
}

export class FakeProjectRegistry implements ProjectRegistry {
  private readonly projects: ReadonlyMap<string, Project>;

  constructor(projects: Project[] = []) {
    this.projects = new Map(projects.map(p => [p.id, p]));
  }

  async getProject(id: string): Promise<Project> {
    const project = this.projects.get(id);
    if (!project) {
      throw new Error(`Project "${id}" not found in FakeProjectRegistry`);
    }
    return project;
  }
}
```

---

## 4. Test Structure: Angry Tests Standard

Every test must follow the **Angry Tests** standard:
1. **One Assertion:** Only one logical assertion per test case.
2. **Assertion Last:** The `expect(...)` call must be the very last line of the test.
3. **Explicit Failure Reason:** Descriptive test name explaining the domain expectation.

```typescript
test('calculates total tender cost from specification items', () => {
  const item1 = new SpecificationItem('1', 'Steel', 'Materials', 500, 2);
  const item2 = new SpecificationItem('2', 'Concrete', 'Materials', 300, 10);
  const matrix = new FakeRfqMatrix([item1, item2]);

  const total = matrix.totalEstimatedCost();

  expect(total).toBe(4000);
});
```

---

## 5. Cross-Platform Audit Commands

Run the following commands to verify test coverage and test execution:

### Windows (PowerShell):
```powershell
# Run all Vitest suites
npx vitest run

# Run coverage report
npx vitest run --coverage

# Scan for banned vi.mock usages in test files
Get-ChildItem -Path "src" -Recurse -Filter "*.spec.ts" | Select-String -Pattern "vi\.mock\("
```

### Linux / macOS (Bash):
```bash
# Run all Vitest suites
npx vitest run

# Run coverage report
npx vitest run --coverage

# Scan for banned vi.mock usages in test files
grep -rn "vi.mock(" src/**/*.spec.ts
```

---

## Review Output Format

If a pull request fails testing invariants:
```
FE-TEST-COVERAGE: REJECT
File: src/views/__tests__/ProjectDetailView.spec.ts:12
Violation: Banned global mock detected (vi.mock('@/api/client')).
Remediation: Remove vi.mock. Define a FakeRfqMatrix class implementing the RfqMatrix interface and inject it via props.
```

If compliant:
```
FE-TEST-COVERAGE: PASS
All user flows have pre-existing tests, verifying public behavior via EO Fakes with 0 global mocks.
```

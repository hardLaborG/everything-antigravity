# Smart Frontend Build Error Resolver Instruction

## Mission
This skill provides automated, incremental diagnostic and resolution procedures for build and type-checking failures in Vue 3 + TypeScript projects. It enforces unbending type integrity, eliminating compiler suppression shortcuts and immutability degradation.

---

## 1. Strictly Banned "Fix" Patterns

The following shortcuts are classified as catastrophic quality violations:

| Banned Pattern | Why It Is Banned | Required Solution |
|---|---|---|
| `const x = (item as any).price;` | Erases compiler type safety and masks runtime defects. | Update domain class interface or add typed discriminator. |
| `// @ts-ignore` | Silences compiler errors without addressing underlying bug. | Fix signature or generic constraint. |
| `// @ts-expect-error` | Masks architectural debt in production paths. | Align contracts and types properly. |
| Removing `readonly` modifier | Breaches EO immutability invariants to allow mutable hacks. | Implement copy-on-write (`withX()`) returning a new instance. |
| `item!.details` (non-null assertion) | Introduces unhandled runtime crash on undefined data. | Use Null-Object pattern or fail-fast guard clause. |

---

## 2. Parsing Build Outputs

### Parsing `vue-tsc -b` output
`vue-tsc` outputs TypeScript diagnostics with file path, line, column, error code, and description:

```
src/views/ProjectDetailView.vue:56:19 - error TS2540: Cannot assign to 'category' because it is a read-only property.

56     item.category = newCategory;
             ~~~~~~~~
```

### Analysis:
- Offending line: `item.category = newCategory;`
- Error: TS2540 (Mutation of readonly property).
- **Prohibited Action:** Removing `readonly category: string;` in `SpecificationItem.ts`.
- **Approved Action:** Replacing mutation with immutable copy method:
  ```typescript
  items.value = items.value.map(i => i.id === item.id ? i.withCategory(newCategory) : i);
  ```

---

## 3. Incremental Resolution Protocol

Follow this 5-step loop strictly:

### Step 1: Capture First Error
Run compiler checks:
```powershell
# Windows
npx vue-tsc -b
```
```bash
# Linux / macOS
npx vue-tsc -b
```
Extract the first reported error block. Ignore subsequent lines.

### Step 2: Contract Inspection
Open the target file and the associated class/interface definitions. Read the contract requirements:
- Is the method expecting a domain class rather than a plain object?
- Is there a missing return type in a pure composable?
- Is a discriminated union missing an exhaustive check?

### Step 3: Implement Pure Architectural Fix
Apply the smallest necessary type-level or object contract fix:
- Do NOT perform unrelated cleanup.
- Do NOT rewrite unrelated methods.
- Keep the diff `<= 25 lines`.

### Step 4: Verify Clean Build
Re-execute:
```bash
npx vue-tsc -b && npx vite build
```
Confirm the targeted error is eliminated and no new errors have been introduced.

### Step 5: Rollback Guard
If the change introduces new errors or the error persists after 2 attempts:
```bash
git checkout -- <file>
```
Re-evaluate the type hierarchy before attempting a new fix.

---

## 4. Cross-Platform Audit Commands

### Scan for Banned Hacks in Git Diff
Ensure no contributor sneaks type suppression hacks into staged changes:

#### Windows (PowerShell):
```powershell
git diff --staged | Select-String -Pattern '(as\s+any|@ts-ignore|@ts-expect-error|\!\s*[\.\,\;\)])'
```

#### Linux / macOS (Bash):
```bash
git diff --staged | grep -E '(as[[:space:]]+any|@ts-ignore|@ts-expect-error|![[:space:]]*[\.,;\)])'
```

If matches are found, **REJECT** the changeset immediately.

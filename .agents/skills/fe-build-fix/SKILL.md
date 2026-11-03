---
name: fe-build-fix
description: |
  Incrementally resolves TypeScript and Vue compilation errors from vue-tsc -b and vite build.
  Strictly bans type-erasure hacks (as any, @ts-ignore, @ts-expect-error, or removing readonly modifiers)
  and fixes errors exclusively through type contracts and architecture adjustments.
parameters:
  type: object
  properties:
    build_command:
      type: string
      description: "Build command to execute (e.g., 'npx vue-tsc -b' or 'npm run build')"
      default: "npx vue-tsc -b"
---

# Smart Frontend Build Error Resolver (vue-tsc & vite)

Incrementally diagnose and resolve compiler errors in Vue 3 and TypeScript applications without compromising type safety or immutability.

## 1. Zero Tolerance for Type-Bypass Hacks (CRITICAL - Instant Reject)

Fixing compiler errors by suppressing TypeScript is **UNCONDITIONALLY FORBIDDEN**.
Any pull request or fix introducing the following will be automatically rejected:
- **`as any` or `as unknown as any`**: Type casting to `any` to silence compiler errors.
- **`// @ts-ignore`**: Suppressing compiler errors on offending lines.
- **`// @ts-expect-error`**: Silencing expected errors in production code.
- **Stripping `readonly` modifiers**: Removing `readonly` from interface, type, or class fields to bypass immutability errors instead of using copy-on-write methods.
- **Non-null assertions (`!`)**: Bypassing possible undefined/null with `!` instead of explicit guards or Null-Objects.

**The Golden Invariant:** Errors must be solved exclusively by correcting the type architecture, refining generic constraints, introducing proper discriminator unions, or updating object contracts.

## 2. Atomic Resolution Workflow

1. **Capture & Parse Failure:**
   - Execute `npx vue-tsc -b` or `npm run build`.
   - Parse the compiler output and isolate the **FIRST** diagnosed error.
   - Ignore all subsequent cascading errors until the root error is addressed.
2. **Localize & Reason:**
   - Inspect the file and line indicated by `vue-tsc` (e.g., `src/views/ProjectDetailView.vue:45:12`).
   - Identify the contract mismatch:
     - Missing property in domain class.
     - Incompatible parameter types in method call.
     - Violation of `readonly` modifier.
     - Unhandled union variant.
3. **Architectural Correction:**
   - Formulate the minimal structural fix:
     - Extend or align the domain class method signature.
     - Add a copy-on-write method (`withX(...)`) if state modification was attempted.
     - Implement proper exhaustiveness checking (`never` type).
4. **Verification & Invariant Check:**
   - Re-run `npx vue-tsc -b` and `vite build`.
   - Verify that the target error is resolved.
   - Diff budget check: fix diff must be **<= 25 lines**.
   - If 2 successive fix attempts fail or produce cascading errors, revert immediately.

## Output Format
If a hack is detected:
`FE-BUILD-FIX: REJECT - Type suppression hack detected (@ts-ignore / as any / readonly removal).`

If cleanly fixed:
`FE-BUILD-FIX: PASS - Resolved [TS-XXXX] in file:line via architectural type contract correction.`

---
name: fe-code-style
description: |
  Audits Vue 3 and TypeScript codebases against Elegant Objects (EO) dogmas and client fault-tolerance rules.
  Bans naked DTOs, procedural API clients, bloated components (>250 lines), null/undefined in business logic,
  and in-place mutation.
parameters:
  type: object
  properties:
    target_path:
      type: string
      description: "Path to Vue component, composable, or TypeScript file to inspect"
  required:
    - target_path
---

# Vue 3 / TypeScript Elegant Objects Architecture Auditor

Inspect frontend codebases (Vue 3, TypeScript, PrimeVue, Axios) against strict Elegant Objects (EO) architecture, immutability, and fault-tolerance constraints.

## 1. No Naked DTO Interfaces (Data with Behavior)
- **Invariant:** Data must never exist separately from behavior.
- **Rule:** Naked interfaces that only declare fields (`interface SpecificationItemDto { id: string; price: number; }`) must NEVER be used directly in business logic or UI views.
- **Mandate:** Raw API payloads (e.g. from `src/types/index.ts`) must be encapsulated inside immutable domain classes with behavioral methods (e.g. `class SpecificationItem` owning `.withCategory()`, `.totalPrice()`, `.matchesFilter()`). Procedural helper functions manipulating anemic data are REJECTED.

## 2. API Object Isolation (No Procedural Client Dumps)
- **Invariant:** APIs must be represented as cohesive, stateful/parameterized objects, not flat procedural modules.
- **Rule:** Flat files exporting collections of functions (e.g. `src/api/client.ts` with 30 exported procedural Axios calls) are **STRICTLY REJECTED**.
- **Mandate:** APIs must be encapsulated into dedicated domain objects (e.g. `class S3Bucket`, `class RfqMatrix`, `class TenderDecisionRegistry`), accepting dependencies (configured Axios instance, base URL, auth token supplier) via constructor injection.

## 3. UI Component Size & Logic Offloading (Max 250 Lines)
- **Invariant:** View components exist exclusively to bind state to visual presentation.
- **Rule:** Single File Components (SFCs like `ProjectDetailView.vue`) must NOT exceed **250 lines of code** (including `<template>`, `<script>`, and `<style>`).
- **Mandate:** Complex business logic (file validation, tender decision calculations, currency formatting, matrix math) must be extracted into:
  1. Dedicated immutable TypeScript domain classes.
  2. Pure composables without side-effects.
- **Composable Naming Rule:** Composable names must NOT contain `-er` suffixes. Use `useAuth` (NOT `useAuthService`), `useTenderProject` (NOT `useTenderManager`).

## 4. Immutability by Default & Readonly State
- **Invariant:** State never mutates in place; state transitions yield new instances.
- **Rule:** All props, reactive refs, and class fields must be declared `readonly` (`readonly` modifier, `Readonly<T>`, or `DeepReadonly<T>`).
- **Mandate:** Modifying an object in-place (e.g. `item.category = newCat`) is FORBIDDEN. Mutations must return a new instance via copy-on-write methods (e.g. `item.withCategory(newCat)`).

## 5. Zero-Null / Fail-Fast Domain Design
- **Invariant:** `null` and `undefined` do not exist in domain business logic.
- **Rule:** Forbid `null` and `undefined` in business logic and component state.
- **Mandate:**
  1. Use the **Null-Object pattern** for empty/initial states (e.g. `NullSupplierProfile`, `NullSpecificationItem`).
  2. Domain error objects: Raw Axios errors (`err.response.data`) must NEVER be forwarded directly to UI Toast components. Translate external network errors into strongly-typed domain error objects (`NetworkFailure`, `UnauthorizedAccess`).
  3. All domain class constructors must validate arguments eagerly (Fail-Fast).

## 6. Frontend Complexity & Size Budgets
- **Function/Method Length:** Maximum **40 lines of code**.
- **Nesting Depth:** Maximum nesting depth is **<= 2** (use guard clauses / early returns).
- **Cyclomatic Complexity:** Cyclomatic complexity of any method/function must be **<= 3**. Higher complexity must be decomposed into dedicated objects.

## Output Format
If violations exist:
`FE-CODE-STYLE: REJECT` followed by exact file:line, the violated dogma, and refactored sample code.

If compliant:
`FE-CODE-STYLE: PASS`

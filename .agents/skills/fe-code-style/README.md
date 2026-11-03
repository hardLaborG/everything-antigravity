# fe-code-style Skill

Vue 3 and TypeScript architecture auditor enforcing Bugayenko's Elegant Objects (EO) dogmas, strict immutability, and fault tolerance.

## Core Rules
- **No Naked DTOs:** Raw API data must be wrapped in immutable domain classes containing business behavior.
- **API Isolation:** Procedural client files (like `client.ts`) are banned. APIs must be domain classes with constructor-injected dependencies.
- **Component Limit:** Vue Single File Components (e.g. `ProjectDetailView.vue`) must stay `<= 250 lines`.
- **Pure Composables:** No `-er` naming suffixes; composables must be pure without import-time side-effects.
- **Immutability:** All state and props are `readonly`; changes occur via copy-on-write (`withX()`).
- **Zero-Null / Fail-Fast:** No `null`/`undefined` in business logic; use Null-Objects and domain errors.
- **Complexity Budgets:** Methods `<= 40` lines, nesting `<= 2`, cyclomatic complexity `<= 3`.

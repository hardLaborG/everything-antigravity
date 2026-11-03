# fe-build-fix Skill

Smart TypeScript and Vue 3 build error resolver for `vue-tsc -b` and `vite build`.

## Principles
- **No Hacks:** `as any`, `// @ts-ignore`, `// @ts-expect-error`, and stripping `readonly` modifiers are strictly banned.
- **Architectural Corrections Only:** Fixes are applied strictly by adjusting type contracts, domain class interfaces, and proper type discrimination.
- **Atomic Incremental Workflow:** Fix errors one by one, verifying the build after each fix. Max diff `<= 25` lines per fix.

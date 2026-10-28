# Rule: Minimalist Patterns and Anti-Patterns

## Forbidden Patterns
1. **Dependency Injection Containers:** Forbid global DI frameworks, reflection-based service locators, and dynamic dependency wiring. Pass dependencies explicitly via constructors.
2. **Singletons:** Forbid global mutable singletons and package-level state.
3. **Procedural Utils:** Forbid utility namespaces (`utils/`, `common/`, `helpers/`). Every function must belong to an instantiated domain object or a cohesive package.
4. **Inheritance for Code Reuse:** Implementation inheritance is banned. Compose objects via interfaces/protocols (`Composition Over Inheritance`).

---

## Allowed Minimalist Patterns
- **Decorators (Wrappers):** Add cross-cutting behavior (logging, caching, metrics) exclusively by wrapping an interface with an identical interface.
- **Null Object:** Replace empty/missing checks with an object providing deterministic no-op behavior.
- **Composite:** Group multiple objects implementing the same interface under a single composite container.
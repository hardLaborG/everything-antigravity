# Rule: Elegant Objects and Code Style Constraints

## Object Architecture Dogmas
1. **Alive Entities, Not Data Bags:**
    - Forbid `-er` suffixes for domain entities (`UserManager`, `DataHelper`, `OrderService`, `TokenController`). Use real-world nouns (`User`, `Tokens`, `Archive`).
    - Exception: Single-method Go interfaces keep standard idiomatic `-er` suffixes (`Reader`, `Writer`).
2. **No DTOs & No Anemic Models:**
    - Forbid structures that hold state without behavior. Keep contracts encapsulating their own processing.
    - Domain models must contain at most 1 to 4 attributes.
3. **No Getters or Setters:**
    - Forbid `get*` and `set*` methods. Objects never expose internal fields; they expose behavior.

---

## Immutability & Zero-Null
- **Immutability by Default:**
    - Objects and domain structures must be strictly immutable once instantiated. In Python, use `@dataclass(frozen=True)`.
    - State transformations must instantiate and return a new instance.
- **Strictly No NULL:**
    - Never pass `nil`/`None`, never return `nil`/`None`. Use Null-Object patterns or explicit Result types.
    - Passing `nil`/`None` into a domain constructor is an invariant violation.

---

## Fail Fast
- Validate all arguments immediately at instantiation.
- In Go: return explicit wrapped errors (`fmt.Errorf("...: %w", err)`) at the point of failure. Never suppress errors.
- In Python: raise dedicated domain exceptions immediately upon precondition violation.

## Method & Complexity Budgets
- **Function/Method Length:** Maximum 70 lines of code. If logic exceeds 70 lines, it must be decomposed.
- **Nesting Depth:** Maximum nesting depth is `<= 3` (use early returns / guard clauses).
- **Cyclomatic Complexity:** McCabe complexity of any single method MUST be `<= 5`. Higher complexity requires decomposition into dedicated objects.

## Security & Boundary Invariants
- **Fail-Fast Construction:** Input validation MUST occur inside object constructors/factories. Reject invalid states immediately upon creation.
- **Parameterized SQL:** Strictly forbid string concatenation, formatting (`fmt.Sprintf`), or interpolation in database queries.
- **Zero Secrets:** Hardcoded credentials, fallback tokens, or raw keys in code/fixtures result in immediate PR rejection.

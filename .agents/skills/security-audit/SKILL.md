Адаптация `skills/security-review`[cite: 33] под строгие бескомпромиссные проверки:

---
name: security-audit
description: |
Audits changes for security vulnerabilities: hardcoded secrets, injection,
insecure dependencies, race conditions, and improper crypto usage.
---

# Strict Security Audit Gatekeeper

Inspect uncommitted changes (`git diff --staged`) against the hard security boundaries.

## 1. Secrets & Credentials (CRITICAL - Instant Reject)
- [ ] No hardcoded API keys, bearer tokens, passwords, private keys (`sk-`, private key PEMs).
- [ ] No secrets committed in test fixtures or mock configurations.
- [ ] Credentials must load strictly from validated environment variables.

## 2. Input Sanitation & Injections (CRITICAL)
- [ ] **SQL/NoSQL:** Parameterized queries strictly required. String concatenation, string formatting (`fmt.Sprintf`), or variable interpolation in queries is FORBIDDEN.
- [ ] **System Execution:** No raw shell invocations (`sh -c`, `os.system`). Require explicit argument vectors.
- [ ] **Boundary Validation:** Arguments validated fail-fast in object constructors.

## 3. Concurrency & Networking
- [ ] Goroutines/threads must have bounded lifecycles controlled via cancellation contexts (`context.Context`).
- [ ] Run race detector: `go test -race ./...` (or equivalent thread sanitizer).
- [ ] Ephemeral network sockets only in tests (no hardcoded ports).

## Output
If any item fails, print:
`SECURITY AUDIT: REJECT` followed by exact file:line and remediation code.
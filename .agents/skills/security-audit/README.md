# security-audit Skill

Strict fullstack security audit gatekeeper enforcing zero secrets, fail-fast boundary validation, and zero SQL injection across Windows and Linux.

## Key Capabilities
- **Cross-Platform Scans:** Built-in scanning scripts for both Windows (PowerShell `Select-String`) and Linux/macOS (Bash `grep`/`ripgrep`).
- **Zero Secrets (Fullstack):** Audits backend and frontend configurations (`vite.config.ts`, `nginx.conf`, `.env*`, Dockerfiles) to prevent secret token leakage into client bundles.
- **Fail-Fast Boundary Validation:** Mandates that all external data entering system boundaries is validated immediately inside constructor invariants of value objects.
- **Parameterized SQL Enforcement:** Immediate rejection of any dynamic query assembly (`+`, `fmt.Sprintf`, `f-strings`, template literals).

## Quick Checklist
- [ ] No hardcoded tokens, keys, passwords, or private PEM blocks.
- [ ] No sensitive credentials exposed to frontend via `VITE_*` or `PUBLIC_*`.
- [ ] External inputs validated via Fail-Fast constructors before domain logic.
- [ ] All database queries (SQL/NoSQL/ClickHouse) are 100% parameterized.
- [ ] No raw shell invocations or uncontained file path traversals.

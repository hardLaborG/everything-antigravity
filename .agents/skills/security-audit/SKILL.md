---
name: security-audit
description: |
  Audits changes for security vulnerabilities: hardcoded secrets (across backend and frontend),
  injection flaws, missing boundary validation/fail-fast constructors, insecure configs, and race conditions.
  Provides cross-platform scanning workflows for both Linux (Bash) and Windows (PowerShell).
---

# Strict Security Audit Gatekeeper

Inspect uncommitted changes (`git diff --staged` or branch diff) against strict security boundaries across fullstack codebases.

## 1. Secrets & Credentials (CRITICAL - Instant Reject)

- **Fullstack Zero Secrets:**
  - Scan backend AND frontend assets: `.env`, `.env.*`, `vite.config.ts`, `nuxt.config.ts`, `vue.config.js`, `nginx.conf`, Dockerfiles, and client source code.
  - No hardcoded API keys, bearer tokens, passwords, private keys (`sk-`, `ghp_`, `xoxb-`, PEM headers `BEGIN PRIVATE KEY`).
  - No secret environment variables leaked into frontend bundles (e.g. database credentials, JWT secret keys, payment secret keys exposed via `VITE_*` or `PUBLIC_*` prefixes).
  - No secrets committed in test fixtures, mocks, or demo code.
  - Credentials must be injected at runtime strictly through validated environment variables or external secret managers.

## 2. Boundary Validation & Fail-Fast Constructors (CRITICAL)

- **Zero-Trust Boundary Validation:**
  - All external data entering the application (HTTP request bodies, route params, query strings, headers, webhook payloads, file uploads) MUST be validated fail-fast in object constructors or boundary value objects.
  - Raw unvalidated dictionaries, plain interfaces, or anemic DTOs passed into business domain logic are **STRICTLY REJECTED**.
  - Constructors must validate ranges, formats, regexes, and non-empty constraints eagerly upon instantiation.
- **Fail-Fast Error Handling:**
  - Malformed external inputs must trigger immediate typed domain validation rejections, not cascade into downstream null dereferences or database exceptions.

## 3. Input Sanitation & Injection Prevention (CRITICAL)

- **SQL / NoSQL / ClickHouse:** Parameterized queries strictly required. String concatenation (`+`), template literals (`` `...${v}...` ``), or string formatting (`fmt.Sprintf`, `f"..."`) in queries is FORBIDDEN.
- **System Execution:** No raw shell invocations (`sh -c`, `cmd.exe /c`, `os.system`). Require explicit argument vectors with strict validation of executable binaries.
- **Path Traversal:** File path parameters from external inputs must be validated against canonical paths (`filepath.Clean`, `path.resolve`) and checked against directory jail roots.

## 4. Concurrency & Network Safety

- Goroutines and async background tasks must have bounded lifecycles governed by cancellation contexts (`AbortController`, `context.Context`).
- Race conditions verified via race detector: `go test -race ./...` (or equivalent thread sanitizer).
- Ephemeral network ports only in tests; no hardcoded production ports in tests.

## 5. Cross-Platform Audit Commands

### Linux / macOS (Bash)
```bash
# Scan for hardcoded credentials & secrets across frontend and backend
git diff --staged | grep -E -i '(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{20,}|BEGIN PRIVATE KEY|password\s*=|secret\s*=|token\s*=)'

# Scan for unsafe query string concatenation
git diff --staged | grep -E '(SELECT|INSERT|UPDATE|DELETE).*\+|(fmt\.Sprintf|f".*SELECT)'
```

### Windows (PowerShell)
```powershell
# Scan for hardcoded credentials & secrets across frontend and backend
git diff --staged | Select-String -Pattern '(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{20,}|BEGIN PRIVATE KEY|password\s*=|secret\s*=|token\s*=)'

# Scan for unsafe query string concatenation
git diff --staged | Select-String -Pattern '(SELECT|INSERT|UPDATE|DELETE).*\+|(fmt\.Sprintf|f".*SELECT)'
```

## Output Format

If any violation is detected:
```
SECURITY AUDIT: REJECT
File: <path/to/file>:<line>
Violation: <Exact security rule violated>
Remediation: <Specific remediation steps or replacement code>
```

If compliant:
```
SECURITY AUDIT: PASS
```

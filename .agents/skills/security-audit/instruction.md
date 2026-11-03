# Strict Security Audit Gatekeeper Instruction

## Overview
This skill operates as an automated security auditor enforcing uncompromising rules against hardcoded secrets, unsafe query assembly, missing boundary validation, and uncontained execution. It enforces full cross-platform compatibility across Windows (PowerShell) and Linux/macOS (Bash).

---

## 1. Zero Secrets Across Fullstack Architectures

### 1.1 Scope of Secret Scans
Security audits must inspect BOTH backend and frontend configurations. In modern SPAs (Vue 3, React, Vite), secrets accidentally embedded into client builds become permanently public in distributed `.js` assets.

**Mandatory Target Files:**
- Environment definitions: `.env`, `.env.local`, `.env.production`, `.env.*`
- Frontend bundler configurations: `vite.config.ts`, `nuxt.config.ts`, `vue.config.js`, `webpack.config.js`
- Reverse proxy and deployment configurations: `nginx.conf`, `Dockerfile`, `docker-compose.yml`, `k8s/*.yaml`
- Source code: All files in `src/`, `api/`, `server/`, `cmd/`

### 1.2 Banned Secret Patterns
1. **API Keys & Tokens:** OpenAI (`sk-...`), GitHub (`ghp_...`, `github_pat_...`), Slack (`xoxb-...`, `xoxp-...`), AWS Access Keys (`AKIA[0-9A-Z]{16}`).
2. **Private Cryptographic Keys:** `-----BEGIN PRIVATE KEY-----`, `-----BEGIN RSA PRIVATE KEY-----`.
3. **Database & Connection Strings:** Connection strings containing passwords (e.g., `postgres://user:password@host/db`).
4. **Frontend Variable Leakage:** Secret environment variables MUST NOT be prefixed with `VITE_` or `NUXT_PUBLIC_`. Frontend environment variables must only contain public URLs and non-sensitive identifiers.

### 1.3 Cross-Platform Secret Scanning Scripts

#### Windows (PowerShell):
```powershell
# 1. Scan staged git diff for leaked secret patterns
git diff --staged | Select-String -Pattern '(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{20,}|AKIA[0-9A-Z]{16}|BEGIN (RSA )?PRIVATE KEY|password\s*[:=]\s*["''][^"'']+["'']|secret\s*[:=]\s*["''][^"'']+["''])'

# 2. Audit frontend configs for exposed sensitive environment variables
Get-ChildItem -Path "vite.config.ts", "nginx.conf", ".env*" -ErrorAction SilentlyContinue | Select-String -Pattern '(SECRET|PRIVATE_KEY|DATABASE_URL|AUTH_SECRET|TOKEN)\s*='
```

#### Linux / macOS (Bash):
```bash
# 1. Scan staged git diff for leaked secret patterns
git diff --staged | grep -E -i '(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{20,}|AKIA[0-9A-Z]{16}|BEGIN (RSA )?PRIVATE KEY|password\s*[:=]\s*["'"'][^"'"']+["'"']|secret\s*[:=]\s*["'"'][^"'"']+["'"'])'

# 2. Audit frontend configs for exposed sensitive environment variables
grep -E -i '(SECRET|PRIVATE_KEY|DATABASE_URL|AUTH_SECRET|TOKEN)\s*=' vite.config.ts nginx.conf .env* 2>/dev/null
```

---

## 2. Boundary Validation via Fail-Fast Constructors

### 2.1 The Invariant
All external data entering the application from untrusted sources (HTTP requests, route parameters, query strings, WebSockets, webhooks, file payloads) must be validated immediately at the entry boundary inside Fail-Fast constructors or value objects.

### 2.2 Prohibited Anti-Patterns
- **Naked DTOs / Plain Interfaces:**
  ```typescript
  // ❌ REJECT: Anemic interface with no invariant protection
  export interface CreateProjectRequest {
    name: string;
    budget: number;
    supplierEmail: string;
  }
  // Passing this naked object into business services permits invalid states to propagate!
  ```

### 2.3 Required Fail-Fast Constructor Pattern
```typescript
// ✅ APPROVED: Fail-Fast Value Object / Entity with strict constructor validation
export class CreateProjectPayload {
  readonly name: string;
  readonly budget: number;
  readonly supplierEmail: string;

  constructor(rawName: unknown, rawBudget: unknown, rawEmail: unknown) {
    if (typeof rawName !== 'string' || rawName.trim().length === 0 || rawName.length > 120) {
      throw new Error(`CreateProjectPayload: invalid project name (must be 1-120 chars)`);
    }
    if (typeof rawBudget !== 'number' || Number.isNaN(rawBudget) || rawBudget <= 0) {
      throw new Error(`CreateProjectPayload: budget must be a positive number, got ${rawBudget}`);
    }
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (typeof rawEmail !== 'string' || !emailRegex.test(rawEmail)) {
      throw new Error(`CreateProjectPayload: invalid email format "${rawEmail}"`);
    }

    this.name = rawName.trim();
    this.budget = rawBudget;
    this.supplierEmail = rawEmail.toLowerCase();
  }
}
```

---

## 3. SQL / NoSQL Injection & String Assembly

- **Absolute Prohibition:** Reject all queries constructed using dynamic string assembly (`+`, `fmt.Sprintf`, `f"..."`, template literals).
- **Mandatory:** Prepared statements or parameterized queries.

### Cross-Platform Query Audit Scripts

#### Windows (PowerShell):
```powershell
git diff --staged | Select-String -Pattern '(SELECT|INSERT|UPDATE|DELETE|DROP|ALTER).*\+|(fmt\.Sprintf|f".*(SELECT|INSERT|UPDATE|DELETE))|`.*SELECT.*(\${)'
```

#### Linux / macOS (Bash):
```bash
git diff --staged | grep -E -i '(SELECT|INSERT|UPDATE|DELETE|DROP|ALTER).*\+|(fmt\.Sprintf|f".*(SELECT|INSERT|UPDATE|DELETE))|`.*SELECT.*(\${)'
```

---

## 4. System Execution & Path Traversal

- **System Calls:** Forbid `exec("sh -c " + cmd)`, `os.system(...)`, or child_process commands using raw strings. Must use fixed binary names with explicit argument arrays.
- **Path Sanitation:** Forbid string path joining from user inputs without resolving and verifying the path stays inside the target boundary directory.

---

## 5. Review Output Format

If any item fails:
```
SECURITY AUDIT: REJECT
File: <path/to/file>:<line>
Violation: <Reason>
Remediation: <Concrete fix or sample code>
```

If all checks pass:
```
SECURITY AUDIT: PASS
```

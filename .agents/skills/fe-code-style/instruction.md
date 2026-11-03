# Vue 3 / TypeScript Elegant Objects Architecture Instruction

## Mission
This skill enforces Elegant Objects (EO) architectural discipline and client-side resilience across Vue 3 and TypeScript applications (such as PrimeVue/Axios codebases). It eliminates procedural sprawl, anemic data anti-patterns, bloated SFC components, and unstable null-handling.

---

## 1. No Naked DTO Interfaces (Data with Behavior)

### Anti-Pattern (Procedural / Anemic Model):
```typescript
// ❌ REJECT: Naked interface separated from behavior (src/types/index.ts)
export interface SpecificationItemDto {
  id: string;
  name: string;
  category: string;
  unitPrice: number;
  quantity: number;
}

// External procedural function operating on dead data bag
export function calculateItemTotal(item: SpecificationItemDto): number {
  return item.unitPrice * item.quantity;
}
export function updateCategory(item: SpecificationItemDto, category: string): void {
  item.category = category; // In-place mutation!
}
```

### Compliant Pattern (Elegant Objects Entity):
```typescript
// ✅ APPROVED: Immutable domain class encapsulating data AND behavior
export class SpecificationItem {
  readonly id: string;
  readonly name: string;
  readonly category: string;
  readonly unitPrice: number;
  readonly quantity: number;

  constructor(id: string, name: string, category: string, unitPrice: number, quantity: number) {
    if (!id || id.trim().length === 0) throw new Error("SpecificationItem: id is required");
    if (!name || name.trim().length === 0) throw new Error("SpecificationItem: name is required");
    if (unitPrice < 0) throw new Error(`SpecificationItem: unitPrice cannot be negative, got ${unitPrice}`);
    if (quantity <= 0) throw new Error(`SpecificationItem: quantity must be positive, got ${quantity}`);

    this.id = id;
    this.name = name;
    this.category = category;
    this.unitPrice = unitPrice;
    this.quantity = quantity;
  }

  totalCost(): number {
    return this.unitPrice * this.quantity;
  }

  withCategory(newCategory: string): SpecificationItem {
    if (!newCategory || newCategory.trim().length === 0) {
      throw new Error("SpecificationItem: newCategory cannot be empty");
    }
    return new SpecificationItem(this.id, this.name, newCategory.trim(), this.unitPrice, this.quantity);
  }
}
```

---

## 2. API Object Isolation (No Procedural Client Dumps)

### Anti-Pattern:
```typescript
// ❌ REJECT: Flat file src/api/client.ts exporting loose procedural functions
import axios from 'axios';

export async function fetchProjects() { return (await axios.get('/api/projects')).data; }
export async function uploadToS3(file: File) { return (await axios.post('/api/s3', file)).data; }
export async function submitRfqMatrix(matrixId: string, data: any) { ... }
```

### Compliant Pattern:
```typescript
// ✅ APPROVED: Cohesive domain objects with constructor-injected dependencies
import type { AxiosInstance } from 'axios';

export interface FileStorage {
  upload(file: File): Promise<string>;
}

export class S3Bucket implements FileStorage {
  private readonly http: AxiosInstance;
  private readonly bucketName: string;

  constructor(http: AxiosInstance, bucketName: string) {
    if (!http) throw new Error("S3Bucket: http client is required");
    if (!bucketName) throw new Error("S3Bucket: bucketName is required");
    this.http = http;
    this.bucketName = bucketName;
  }

  async upload(file: File): Promise<string> {
    if (file.size === 0) throw new Error("S3Bucket: cannot upload empty file");
    const formData = new FormData();
    formData.append("file", file);
    formData.append("bucket", this.bucketName);
    const response = await this.http.post<{ fileUrl: string }>("/storage/upload", formData);
    return response.data.fileUrl;
  }
}

export class RfqMatrix {
  private readonly http: AxiosInstance;
  readonly matrixId: string;

  constructor(http: AxiosInstance, matrixId: string) {
    if (!http) throw new Error("RfqMatrix: http client is required");
    if (!matrixId) throw new Error("RfqMatrix: matrixId is required");
    this.http = http;
    this.matrixId = matrixId;
  }

  async calculateDecisions(): Promise<TenderDecisions> {
    const res = await this.http.get(`/rfq/${this.matrixId}/decisions`);
    return new TenderDecisions(res.data);
  }
}
```

---

## 3. UI Component Offloading (Max 250 Lines)

### Constraints:
1. **Line Budget:** No Single File Component (`.vue`) may exceed **250 total lines**.
2. **Separation of Concerns:** Component script blocks exist solely to bind user interactions to domain actions.
3. **Pure Composables:** Composables must be pure functions orchestrating reactive references, without hidden network side-effects during import.
4. **Naming Convention:** Composable names MUST NOT contain `-er` suffixes (`Manager`, `Helper`, `Service`).
   - Use `useAuth`, NOT `useAuthService`.
   - Use `useTenderProject`, NOT `useTenderManager`.
   - Use `useMoneyFormat`, NOT `useMoneyFormatter`.

---

## 4. Immutability by Default

- **Readonly State:** All component props and internal state must be wrapped in `readonly(...)` or declared with `readonly` properties.
- **Copy-on-Write Transitions:** State transitions are performed by instantiating new values.
```typescript
// ❌ REJECT:
state.items[0].quantity = 5;

// ✅ APPROVED:
items.value = items.value.map(item => 
  item.id === targetId ? item.withQuantity(5) : item
);
```

---

## 5. Zero-Null & Domain Error Objects

### 5.1 Null-Object Pattern
Replace `null` and `undefined` with typed Null-Objects providing safe default behavior:
```typescript
export interface SupplierProfile {
  readonly id: string;
  readonly name: string;
  readonly rating: number;
  isRegistered(): boolean;
}

export class NullSupplierProfile implements SupplierProfile {
  readonly id = "";
  readonly name = "Unassigned Supplier";
  readonly rating = 0;

  isRegistered(): boolean {
    return false;
  }
}
```

### 5.2 Domain Error Objects (No Raw Axios Toast Dumps)
```typescript
// ❌ REJECT: Raw Axios error passed to Toast
catch (err: any) {
  toast.add({ severity: 'error', summary: 'Error', detail: err.response.data.message });
}

// ✅ APPROVED: Domain error conversion
export class DomainError {
  readonly message: string;
  readonly userMessage: string;

  constructor(message: string, userMessage: string) {
    this.message = message;
    this.userMessage = userMessage;
  }

  static fromNetwork(error: unknown): DomainError {
    if (axios.isAxiosError(error) && error.response?.status === 403) {
      return new DomainError("Forbidden", "You do not have permission to perform this tender action.");
    }
    return new DomainError("NetworkError", "Unable to complete request. Please try again later.");
  }
}
```

---

## 6. Complexity Budgets

| Metric | Threshold | Action on Breach |
|---|---|---|
| Function/Method Length | `<= 40 lines` | Decompose into smaller focused methods |
| Nesting Depth | `<= 2` | Invert conditions, use guard clauses |
| Cyclomatic Complexity | `<= 3` | Extract branches into polymorphic objects |
| SFC Component Total Lines | `<= 250 lines` | Extract subcomponents and domain classes |

---

## Review Output Format

If violations are found:
```
FE-CODE-STYLE: REJECT
File: src/views/ProjectDetailView.vue:1
Violation: Component exceeds 250 lines budget (current: 312 lines).
Remediation: Extract RfqMatrix table logic and TenderDecision actions into dedicated subcomponents and domain classes.
```
If clean:
```
FE-CODE-STYLE: PASS
```

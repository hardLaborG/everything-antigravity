---
name: code-review
description: |
  Audits git diff or PR against Bugayenko's Elegant Objects and strict quality rules.
---

# Strict Code Review Inspection

Inspect the diff (`git diff` or PR branch) against the following hard checklist.

## 1. Budget and Scope Check
- [ ] Is total diff `<= 100` lines (`git diff --stat`)? If `> 100`, reject: "Exceeds 100-line budget".
- [ ] Is only one logical concern addressed? Reject if multiple features or bug fixes are bundled.

## 2. Object & Architecture Dogmas
- [ ] **No -er names:** Reject classes/structs ending with `Manager`, `Helper`, `Util`, `Controller`, `Service`.
- [ ] **No getters/setters:** Reject `getX()` / `setX()`. Objects must expose behavior, not data.
- [ ] **No DTOs / anemic data:** Structs/classes must contain behavior, not just naked fields.
- [ ] **Zero-Null:** Reject returning or accepting `nil`/`None` where an explicit type, Null Object, or Result is possible.
- [ ] **Immutability:** Reject mutating state in place. Transformations must yield new instances.
- [ ] **Composition over inheritance:** Reject class inheritance for code reuse.

## 3. Test & Verification Quality
- [ ] Was a test added/updated?
- [ ] Does the test follow Angry Tests (one assertion, assertion last)?
- [ ] Are mocking frameworks (`unittest.mock`, reflection mocks) avoided in favor of interface fakes?

## Output Format
List violations with file path and line number. If violations exist, declare **REJECT** with actionable decomposition instructions.
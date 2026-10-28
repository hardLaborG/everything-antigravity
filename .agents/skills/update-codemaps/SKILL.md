---
name: update-codemaps
description: |
  Scans project modules and updates token-lean architecture summaries in docs/codemaps/.
---

# Token-Lean Codemap Generator

Scan repository structure and maintain high-level architecture maps without bloated prose.

## Targets
Generate or update the following documents:
- `docs/codemaps/architecture.md`: High-level domain entities, packages, and dependency graph.
- `docs/codemaps/contracts.md`: Core interfaces and public boundary definitions.

## Constraints
- Focus strictly on interfaces, exported symbols, and data flow.
- Exclude internal method bodies and private implementation details.
- Codemap updates must fit within the `<= 100` lines diff budget per file.
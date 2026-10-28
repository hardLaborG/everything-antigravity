---
name: continuous-learning
description: |
  Extracts reusable debugging techniques, non-obvious workarounds,
  and architecture decisions from the current session and saves them as project notes.
parameters:
  type: object
  properties:
    pattern_type:
      type: string
      enum: ["error-resolution", "debugging-technique", "workaround", "project-convention"]
      description: "Category of the learned pattern"
    title:
      type: string
      description: "Short declarative title (e.g., 'clickhouse-async-insert-fallback')"
    problem:
      type: string
      description: "Exact problem, compiler error, or bottleneck encountered"
    solution:
      type: string
      description: "Concrete fix or pattern that resolved the issue"
  required:
    - pattern_type
    - title
    - problem
    - solution
---

# Continuous Learning Protocol

Extract reusable knowledge without saving trivial syntax typos or one-off third-party outages.

## Trigger Conditions
Run this skill when:
1. A tricky bug or edge case was identified and solved.
2. A non-obvious tool/compiler workaround was implemented.
3. An invariant or domain convention for the current repository was established.

## Format & Storage
Append or create a concise markdown note under `docs/learned/{title}.md`:

# {title}

- **Category:** {pattern_type}
- **Date:** YYYY-MM-DD

## Problem
{problem}

## Resolution
{solution}

Diff MUST NOT exceed 40 lines.

---

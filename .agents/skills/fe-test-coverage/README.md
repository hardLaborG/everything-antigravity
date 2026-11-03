# fe-test-coverage Skill

Vitest testing quality gatekeeper enforcing Test-First workflows, black-box behavioral testing, and zero `vi.mock` module spoofing.

## Key Rules
- **Test-First Requirement:** Critical user flows (such as `ProjectDetailView.vue` and API communication) must have tests before refactoring or feature additions.
- **Behavioral Testing:** Test public DOM output and object interactions as a black box; never probe private reactive state.
- **Zero Global Mocks:** `vi.mock` is banned. Use typed Fake implementations and Null-Objects implementing explicit interfaces.
- **Angry Tests:** Exactly one assertion per test, placed as the final line.

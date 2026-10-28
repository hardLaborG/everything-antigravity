# Rule: Performance & YAGNI

## Anti-Overengineering Invariants
1. **No Speculative Optimization:** Never write complex concurrency, caching layers, or memory pools without a reproduction benchmark proving a bottleneck.
2. **Maintainability Over Density:** Do not compress readable algorithms into dense one-liners (e.g., cryptic nested ternary operators or incomprehensible regexes) under the guise of performance.
3. **Clean Teardown:** Every allocation of resources (file descriptors, sockets, goroutines) must have an explicit and bounded lifetime via `defer` or context cancellation.

---

## Benchmarking Protocol
- If performance optimization is required, introduce a benchmark first.
- Optimization commits MUST contain the benchmark diff alongside the change and prove throughput/allocation improvement without violating domain immutability.
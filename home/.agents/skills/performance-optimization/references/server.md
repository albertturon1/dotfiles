# Server Performance

Use for performance problems involving server-side execution, APIs, background workers, request processing, and long-running services.

Follow the measurement workflow in `SKILL.md`.

## Identify the Objective

Select metrics based on the actual problem:

- **Latency:** p50/p95/p99, request duration, queueing time.
- **Throughput:** requests or jobs per second under representative load.
- **CPU:** utilization, hot paths, profiling samples.
- **Memory:** heap usage, allocation rate, garbage collection, leaks.
- **I/O:** database queries, network calls, disk operations, transfer sizes.
- **Concurrency:** active tasks, contention, queue depth, backpressure.
- **Saturation:** resource limits, connection pools, thread or worker exhaustion.

Distinguish execution time from waiting on dependencies, queues, or resources.

## Diagnose

Use tools appropriate to the runtime:

- CPU, memory, and allocation profilers.
- Distributed tracing and request-level timing.
- Database query analysis and execution plans.
- Load testing with representative traffic and concurrency.
- Runtime-specific diagnostics, such as Go pprof or Node.js profiling.

Measure at realistic load levels. Examine tail latency, not just averages.

Identify whether the bottleneck is CPU, memory, I/O, contention, or saturation.

## Investigate

Based on profiling evidence, consider:

- Unnecessary or repeated I/O operations.
- Sequential independent work and excessive waiting.
- Inefficient batching, streaming, or connection reuse.
- Excessive concurrency, contention, or queueing.
- Expensive serialization, allocations, or transformations.
- Inefficient algorithms and data access patterns.
- Blocking operations on critical execution paths.
- Unnecessary retries or redundant computation.

These are potential causes, not automatic fixes.

## Guardrails

- Benchmark under comparable load, configuration, and conditions.
- Measure throughput and latency together; improving one may degrade the other.
- Respect resource limits, timeouts, cancellation, and backpressure.
- Avoid unbounded concurrency and uncontrolled load generation.
- Verify correctness under concurrent execution.
- Account for downstream services and shared infrastructure.
- Do not run disruptive load tests against production.
- Prefer demonstrated improvements over synthetic benchmark wins.

---
name: performance-optimization
description: Diagnose and optimize code performance through measurement-driven experiments. Use for performance audits, slow code, regressions, frontend rendering, latency, throughput, CPU, memory, I/O, and resource bottlenecks across any language or runtime.
---

# Performance Optimization

Improve measurable performance, not code aesthetics.

Follow: **Define → Measure → Diagnose → Hypothesize → Experiment → Verify**.

## Modes

- **Audit:** Investigate bottlenecks, collect evidence, and prioritize opportunities. Do not modify code.
- **Optimize:** Investigate, implement targeted improvements, measure results, and iterate.

Infer the mode from the user's request.

## Workflow

1. **Define** — Identify the workload, performance objective, relevant metrics, and constraints.
2. **Measure** — Establish a reproducible baseline using representative inputs and appropriate profiling or benchmarking tools.
3. **Diagnose** — Locate the highest-impact bottleneck. Distinguish symptoms from underlying causes.
4. **Hypothesize** — Identify the specific cost and propose a targeted improvement with an expected outcome.
5. **Experiment** — Make the smallest meaningful change. Preserve correctness and isolate significant variables where possible.
6. **Verify** — Re-measure under comparable conditions, account for noise and regressions, and keep or revert the change based on evidence.

Repeat while further improvements justify their cost.

## Diagnostic Areas

Consider these when relevant to the bottleneck:

- **Unnecessary work:** redundant computations, repeated operations, caching, early exits.
- **Algorithms & data:** complexity, data structures, passes, representations.
- **I/O & transfers:** calls, payload sizes, batching, streaming.
- **Critical path & concurrency:** dependencies, blocking, parallelism, contention.
- **Memory:** allocations, copies, garbage collection, locality.
- **Runtime-specific costs:** rendering, layout, serialization, syscalls, scheduling.

Use these to generate hypotheses, not as a checklist to exhaust.

## Runtime Guidance

Select references based on the performance domain, not merely the language or framework.

Available references:

- [Browser](references/browser.md) — Page loading, hydration, rendering, and client-side interactions.
- [Server](references/server.md) — Request processing, server-side computation, I/O, concurrency, and resource usage.

Read only references relevant to the investigation. Use multiple when necessary.

For other workloads, use profiling tools and metrics appropriate to the language, runtime, and workload.

Apply only relevant techniques. Never assume an optimization transfers across environments.

## Rules

- Prioritize demonstrated bottlenecks over speculative improvements.
- Optimize impact, not abstract best practices or micro-optimizations.
- Use representative workloads and comparable measurement conditions.
- Distinguish latency, throughput, memory, CPU, and user experience.
- Evaluate trade-offs, including complexity and resource consumption.
- Preserve behavior and run relevant correctness tests.
- Never invent measurements or claim unverified speedups.
- If measurement is unavailable, distinguish hypotheses from findings, explain the limitation, and provide a verification plan.
- Do not discard unrelated or pre-existing changes when reverting experiments.
- Stop when further optimization is unlikely to justify its cost.

## Reference Coverage

Report a missing reference only when all conditions hold:

1. The workload represents a distinct, reusable performance domain not covered by existing references.
2. Missing guidance materially limited measurement, diagnosis, or verification.
3. Existing references and standard runtime-specific tools could not adequately address the gap.

Do not suggest references merely for unsupported languages or frameworks.

Mention qualifying gaps briefly in the final report. Never create new references unless requested.

## Output

Report concisely:

- **Objective:** Target metric or behavior.
- **Bottleneck:** Evidence and root cause, or explicitly unverified hypothesis.
- **Change:** What was optimized and why (Optimize mode).
- **Result:** Before/after measurements, or explicitly unverified.
- **Trade-offs:** Regressions, costs, or limitations.
- **Next:** Remaining worthwhile opportunities, if any.

In Audit mode, prioritize findings instead of reporting implemented changes.

# Browser Performance

Use for performance problems involving browser execution, rendering, loading, or user interactions.

Follow the measurement workflow in `SKILL.md`.

## Identify the Objective

Select metrics based on the actual user-visible problem:

- **Loading:** LCP, resource timing, network waterfalls, critical request chains.
- **Responsiveness:** INP, long tasks, main-thread blocking.
- **Rendering:** frame drops, layout, paint, compositing.
- **Visual stability:** CLS, unexpected layout shifts.
- **Memory:** heap growth, retained objects, detached DOM nodes.
- **Delivery:** JavaScript and asset sizes, parsing, compilation, execution.

For issues spanning browser and server, attribute costs to the correct environment before optimizing.

## Diagnose

Use appropriate tools:

- Browser DevTools Performance, Network, and Memory panels.
- Web Vitals and Lighthouse where relevant.
- Framework-specific profilers when applicable.
- Real-user measurements when available.

Use representative devices, network conditions, and interactions.

Distinguish laboratory measurements from real-user performance.

## Investigate

Based on profiling evidence, consider:

- Unnecessary rendering or expensive updates.
- Excessive DOM size and layout recalculations.
- Long-running JavaScript blocking interactions.
- Repeated computations on critical paths.
- Network waterfalls and unnecessary requests.
- Large or unnecessarily loaded JavaScript and assets.
- Expensive image loading, decoding, or rendering.
- Memory leaks and excessive allocation pressure.

These are potential causes, not automatic fixes.

## Guardrails

- Prioritize user-perceived performance.
- Don't assume fewer renders always mean faster interactions.
- Don't introduce memoization, caching, or virtualization without justification.
- Preserve accessibility, behavior, and visual correctness.
- Verify improvements under comparable conditions.
- Prefer meaningful improvements over synthetic benchmark wins.

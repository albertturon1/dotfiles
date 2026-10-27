---
name: code-maintainability
description: Analyze and refactor code to reduce maintenance friction, unnecessary complexity, coupling, and fragile abstractions. Use for maintainability reviews, code simplification, design problems, and behavior-preserving refactoring. Do not activate solely for ordinary feature implementation.
---

# Code Maintainability

Make code easier to understand, change, and verify.

Optimize for reduced maintenance friction, not aesthetics, fewer lines, or abstract best practices.

## Modes

- **Audit:** Identify and prioritize concrete maintainability problems. Do not modify code.
- **Refactor:** Address justified problems through focused, behavior-preserving changes.

Infer the mode from the user's request.

## Workflow

1. **Understand** — Inspect behavior, dependencies, contracts, and constraints.
2. **Identify friction** — Find concrete obstacles to understanding, changing, or verifying the code.
3. **Prioritize** — Rank issues by actual maintenance impact, not stylistic preferences.
4. **Justify** — Explain why a change would reduce complexity or future maintenance effort.
5. **Refactor** — In Refactor mode, make focused, behavior-preserving changes.
6. **Verify** — Check correctness, contracts, and regressions after changes.
7. **Evaluate** — Keep changes only when the improvement outweighs added complexity and risk.

In Audit mode, stop after providing prioritized, justified recommendations.

## Diagnostic Areas

Investigate when relevant:

- **Readability:** unclear intent, hidden behavior, difficult control flow.
- **Complexity:** unnecessary branches, indirection, special cases.
- **Responsibilities:** unrelated concerns, scattered ownership.
- **Coupling & cohesion:** change propagation, implicit dependencies.
- **Abstractions & duplication:** premature generalization, misleading abstractions, knowledge duplication.
- **State & contracts:** unclear invariants, state ownership, hidden side effects.
- **Testability:** brittle tests, difficult isolation, excessive setup.

These are diagnostic lenses, not rules to enforce mechanically.

## Existing Code & Standards

- Existing code is evidence, not authority. Never copy patterns solely for consistency.
- Best practices are heuristics, not laws. Evaluate their applicability.
- Respect required contracts, technical constraints, and tooling policies.
- Follow specific reference implementations explicitly designated by the user, within their intended scope.
- Prefer the simplest justified design over both blind imitation and speculative redesign.
- Apply relevant language and framework knowledge without assuming existing patterns are optimal.

## Guardrails

- Every refactor must address identifiable maintenance friction.
- Ground findings in specific code and explain their practical maintenance cost.
- Do not treat code length, duplication, or abstraction count as problems by themselves.
- Prefer reducing complexity over moving it elsewhere.
- Avoid speculative abstractions. Introduce them when they solve current problems or support concrete, foreseeable changes.
- Prefer the smallest abstraction that provides the needed flexibility.
- Consider the cost of adding an abstraction now versus introducing it later.
- Do not merge independent responsibilities merely to eliminate duplication.
- Preserve observable behavior and public contracts unless explicitly authorized otherwise.
- Keep changes focused. Avoid unrelated rewrites and formatting churn.
- Do not turn a maintainability task into performance optimization.
- Do not discard unrelated or pre-existing changes.
- If verification is incomplete, report the remaining uncertainty.
- No change is a valid outcome when improvements are not justified.

## Output

Report concisely:

- **Friction:** Concrete issue and why it matters.
- **Change:** What was simplified and why, if applicable.
- **Verification:** Checks performed and remaining uncertainty.
- **Trade-offs:** New complexity, risks, or limitations.

In Audit mode, prioritize findings rather than reporting changes.

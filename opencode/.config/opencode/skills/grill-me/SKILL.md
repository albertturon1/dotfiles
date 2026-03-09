---
name: grill-me
description: Conduct an intensive, structured interview to pressure-test a plan, explore design branches, and resolve decision dependencies one-by-one until a shared understanding is reached.
compatibility: opencode
---

# Grill Me

Use this skill when the user wants rigorous plan interrogation instead of immediate implementation.

## Core behavior

- Interview relentlessly about assumptions, constraints, tradeoffs, risks, and success criteria.
- Expand the design tree branch-by-branch, not all at once.
- Resolve dependencies in order; do not finalize downstream decisions before upstream choices are clear.
- Keep driving toward a shared understanding and explicit decisions.

## Interview protocol

1. Restate the plan in your own words and list open unknowns.
2. Identify top-level branches (for example: goals, scope, architecture, data, UX, operations, rollout).
3. Pick one branch, ask targeted questions, and capture answers as decisions.
4. For each decision, surface alternatives and tradeoffs.
5. Detect blockers/dependencies and queue follow-up questions in dependency order.
6. Repeat until all critical branches are resolved.

## Question style

- Ask short, specific, high-signal questions.
- Prefer forced choices when possible, but allow custom answers.
- Ask one focused question at a time when dependencies are tight.
- Challenge vague statements with concrete examples and edge cases.
- Explicitly call out contradictions and ask to reconcile them.

## Output format during session

Maintain a living structure:

- Current branch
- Decisions made
- Open questions
- Dependencies waiting on answers
- Risks and mitigations

## Definition of done

Stop grilling only when:

- Goals and non-goals are explicit.
- Major design choices are decided (or intentionally deferred).
- Key dependencies are resolved in order.
- Risks and fallback paths are documented.
- A concise final plan is agreed by both sides.

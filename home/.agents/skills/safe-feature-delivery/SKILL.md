---
name: safe-feature-delivery
description: Use when implementing large features, risky refactors, migrations, or splitting large PRs. Design changes as reversible, independently deployable steps using expand/contract.
---

# Safe Feature Delivery

Implement large changes incrementally. Keep each step deployable and reversible for as long as possible.

## Workflow

1. Inspect the affected code and identify breaking changes, side effects, and one-way doors.
2. Find the smallest backward-compatible implementation that can ship independently.
3. Split the work into logical, stacked PRs:
   - **Expand:** Add new functionality without removing or breaking existing behavior.
   - **Migrate:** Gradually switch behavior or data, validating in production.
   - **Contract:** Remove old paths and compatibility layers after validation.
4. Use feature flags when they help separate deployment from activation.
5. Implement and test each step independently.

## Rules

- Prefer reversible changes over big-bang replacements.
- Keep old and new paths compatible during migration.
- Every PR must leave the system deployable.
- Define how to verify and roll back each step.
- Delay destructive or irreversible operations until explicitly approved.
- Never assume `git revert` reverses external side effects.
- Don't force exactly three PRs; use the minimum safe number.
- Don't introduce flags or abstractions without a concrete reason.

## Output

Before implementing, provide a concise plan:

| PR  | Changes | Reversible? | Verification |
| --- | ------- | ----------- | ------------ |

Highlight the one-way door and explain when it is safe to cross.

Then implement the requested scope, stopping before irreversible actions that require approval.

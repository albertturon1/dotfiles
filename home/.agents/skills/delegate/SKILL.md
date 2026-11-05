---
name: delegate
description: Delegate work to another model or subagent, down to a cheaper model for mechanical work or up to a stronger one for review. Use when the user says delegate, "zleć", "deleguj", subagent, haiku, flash, or asks another model for a second opinion.
---

# Delegate

## Steps

1. **Role.** Choose one: `implement`, `verify`, `review`, or `research`. The cheap tier takes mechanical, well-specified, checkable work (seed data, mechanical UI edits, test runs, verification). The strong tier takes review and diagnosis. Design decisions stay with the user. Done when the brief can name exactly one role.
2. **Model.** Resolve in this order:
   1. A model named in the user's prompt wins. Use it without asking about conflicts.
   2. Otherwise the tier line (`cheap` or `strong`) in `~/.agents/models.md`.
   3. When both are missing, stop delegating. Tell the user `~/.agents/models.md` lacks the tier, show the line format (`- cheap: providerInstanceId=… model=… effort=…`), and resume once the user fills it or names a model.
3. **Git behavior.** The user's prompt decides. Default: the delegate makes no commit, merge, push, or branch switch.
4. **Brief.** Write it with these fields:
   - Goal.
   - Working directory (absolute path; the delegate stays there).
   - Read first (repo `AGENTS.md` and the docs it points to).
   - Role constraints: `verify`, `review`, and `research` are read-only ("Do not edit files"); `implement` edits only inside the working directory.
   - Git behavior (step 3).
   - Done when (a checkable condition).
   - Report: branch, working directory, commands run with results, PASS/FAIL, absolute artifact paths.
5. **Dispatch** through the harness's own mechanism: `delegate_task` in T3 Code (`target` = `{providerInstanceId, model, options: {effort}}` from the tier line; call `orchestrator_capabilities` once per thread first), the Agent tool in Claude Code, the native subagent elsewhere.
6. **Post-check** before accepting the report. Run these in the delegate's directory:
   - `git status --porcelain`, `git branch --show-current`, `git log <base>..HEAD --oneline`, `git diff --stat`;
   - confirm each artifact path exists;
   - confirm no command the delegate started is still running.

   Expected: `verify`/`review`/`research` leave `git status` empty. `implement` without commit permission adds no commits, keeps the branch, and touches only paths that match the goal. Any deviation goes to the user before the task counts as done.

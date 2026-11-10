---
name: delegate
description: Delegate work to another model or subagent, down to a cheaper model for mechanical work or up to a stronger one for review. Use when the user says delegate, "zleć", "deleguj", subagent, haiku, flash, or asks another model for a second opinion.
---

# Delegate

Worked cases: [EXAMPLES.md](EXAMPLES.md).

## Steps

1. **Worth it.** Delegate when all three hold:
   - **Self-contained.** A stranger could execute the brief without asking a question. Decisions are closed and written down.
   - **Checkable.** `implement` and `verify` end in an observation (command output, test, screenshot, diff). `review` ends in findings with confidence levels. `research` ends in claims with cited sources.
   - **Gain.** Work runs in the background while the conversation continues, or a cheaper model takes mechanical work whose frame is already set.

   Do it yourself when the task is small, a design decision is still open, or nothing can check the result. When the user said "deleguj" and one condition fails, name it and ask. Done when all three hold, or you named the failing one.

2. **Role.** Choose one: `implement`, `verify`, `review`, or `research`. The cheap tier takes mechanical, well-specified, checkable work (seed data, mechanical UI edits, test runs, verification). The strong tier takes review and diagnosis. Design decisions stay with the user. Done when the brief can name exactly one role.
3. **Model.** Resolve in this order:
   1. A model named in the user's prompt wins. Use it without asking about conflicts.
   2. Otherwise the tier line (`cheap`, `standard` or `strong`) in `~/.agents/models.md`, chosen by the rules in that file. Default to `cheap`.
   3. When both are missing, stop delegating. Tell the user `~/.agents/models.md` lacks the tier, show the line format (`- cheap: providerInstanceId=… model=… effort=…`), and resume once the user fills it or names a model.
4. **Git behavior.** The user's prompt decides. Default: the delegate makes no commit, merge, push, or branch switch.
5. **Baseline.** Before dispatch, in the delegate's working directory, record: `git status --porcelain`, `git branch --list`, `git worktree list`, `git tag --list`, `git stash list`, the current commit (`<base>`), and the time. Create an artifact directory outside the repository that is unique to this run (the session scratchpad when the harness provides one, otherwise a new directory under the system temp directory). Done when the baseline and the directory path are saved for the brief and the post-check.
6. **Brief.** Write it with these fields:
   - Goal.
   - Working directory (absolute path; the delegate stays there).
   - Read first: repo `AGENTS.md` and the docs it points to. For a large task, also the spec the user produced with `/to-spec`; only the user can run it, so ask where it lives. A small task carries its decisions in the brief.
   - Role constraints: `verify`, `review`, and `research` make no change inside the repository; `implement` edits only inside the working directory.
   - Git behavior (step 4), and `<base>`.
   - Artifact directory (step 5): everything the delegate saves goes there.
   - Done when: evidence the delegate chooses to fit the work, of a kind that could have shown failure. Per role:
     - `implement`: a check that fails before the change and passes after it. The tests exist before dispatch, or the delegate writes them first and shows them failing.
     - `verify`: an observation of the current state, with every uncovered outcome marked `NOT-COVERED` and a reason.
     - `review`: each finding carries one confidence level. `confirmed` has a saved reproduction (script or command, output file) made in the artifact directory; `unverified` is read from code and says how to check it; `style` is a judgement call with no proof owed.
     - `research`: each claim cites a URL and the passage.
   - Report: branch, working directory, and for each command its text, exit code, the path of its captured output file, and a short excerpt; PASS/FAIL/NOT-COVERED per outcome; processes started (with ports); absolute artifact paths.
7. **Dispatch** through the harness's own mechanism: `delegate_task` in T3 Code (`target` = `{providerInstanceId, model, options: {effort}}` from the tier line; call `orchestrator_capabilities` once per thread first), the Agent tool in Claude Code, the native subagent elsewhere.
8. **Post-check** before accepting the report.
   - Record the same baseline again and compare. Every difference goes to the user, except paths the goal names.
   - `implement` without commit permission leaves changes uncommitted: read them with `git diff HEAD`, not `git diff <base>...HEAD`.
   - Each artifact path exists and is newer than the dispatch time. Each process the report names has stopped.
   - Choose the highest-impact claim yourself (not the delegate's first) and reproduce it: rerun its command, or for `review` rerun a `confirmed` reproduction, and compare with the captured output.
   - State in your own report which outcomes you observed and which you took from the delegate.

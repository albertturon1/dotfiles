# Examples

Worked cases for [SKILL.md](SKILL.md). Pick the nearest one; adapt the shape, not the wording. `<artifacts>` stands for the run's artifact directory from step 5.

## Do it yourself

- A two-file rename. The brief costs as much as the edit.
- "Make the settings screen feel better." The design decision is open, and nothing can check done.
- A fix that depends on what was said ten messages ago and was never written down. Write it down first, then decide again.

## Implement in the background (cheap tier)

Situation: the decisions are closed in the user's spec and the conversation moves on to the next feature.

```
Goal: implement CSV export as specified.
Working directory: /Users/work/app
Read first: AGENTS.md, and the spec at <location the user gave> (sections "Implementation Decisions", "Testing Decisions").
Role: implement. Edit only inside /Users/work/app. No commit, merge, push, or branch switch. Base: <sha>.
Artifact directory: <artifacts>
Done when, with evidence you choose:
  - a check for the export exists, fails before your change, and passes after it;
  - the endpoint returns a CSV whose first line is the header row `id,name,created_at`.
Report: for each command its text, exit code, output file path, excerpt; PASS/FAIL per line above; processes started with ports; artifact paths.
```

Post-check: compare the baseline, read `git diff HEAD`, then rerun the check that matters most to you.

## Verify with a browser (cheap tier)

Situation: the change is finished, and you want proof in the real UI without spending the main context.

```
Role: verify. Make no change inside the repository.
Read first: AGENTS.md, then run `agent-browser skills get core`.
Artifact directory: <artifacts>
Done when, for each outcome, a screenshot in <artifacts> and the page text that shows it:
  1. Empty cart shows "Your cart is empty".
  2. With one item, the total equals the item price.
  3. With the API aborted, the error banner appears (include the request log).
Report: per outcome PASS/FAIL/NOT-COVERED with the reason, absolute screenshot paths, the port of the dev server you started.
```

Post-check: open at least one screenshot you choose yourself.

## Review (strong tier)

```
Role: review. Make no change inside the repository.
Goal: find defects in the uncommitted change (`git diff HEAD`) against the decisions in <location>.
Artifact directory: <artifacts>
Done when: every changed file is listed with "no finding" or a finding that names the input and the wrong output.
Mark each finding confirmed (a reproduction script and its output saved in <artifacts>), unverified (say how to check), or style.
Report: findings ranked by severity.
```

Post-check: compare the baseline. Rerun the reproduction of the finding that would cost most if wrong. Treat `unverified` findings as questions, not defects.

## Research (cheap or strong tier)

```
Role: research. Make no change inside the repository.
Goal: find how <library> handles <case>.
Done when: each claim cites the URL and quotes the passage; a claim with no source is listed under "not found".
Report: claims with sources, then "not found".
```

Post-check: open the source of the claim you rely on most.

## Briefs that go wrong

| Brief | Why it fails |
|---|---|
| "Implement what we discussed." | The discussion is not in the delegate's context. Point to a file or put the decisions in the brief. |
| "Done when it works." | Nothing observable, so the report can say PASS about anything. |
| "Report a summary of what you did." | A summary hides the evidence. Ask for captured output paths. |
| One brief with `implement` and `review` | The author reviews their own work. Dispatch the review as a separate delegate. |
| "Save screenshots in /tmp/verify" | Two parallel delegates collide, and old files pass "path exists". Give each run its own directory. |

## Where the decisions come from

Decisions go stale quickly, so keep them out of the repository and scope them to one task.

- Large task: the user runs `/to-spec` and keeps the result out of the repository. You never invoke it. Ask the user where the spec lives, then name its "Implementation Decisions", "Testing Decisions", and "Out of Scope" sections in the brief. The user stories add length without adding frame.
- Medium task: a short decisions note in the scratchpad directory, deleted when the task ends.
- Small task: the decisions sit in the brief; no file.

Whichever form you use, state in "Done when" how the result will be observed: a spec says what to build, not how you will check it.

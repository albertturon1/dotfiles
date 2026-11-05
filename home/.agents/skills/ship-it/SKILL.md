---
name: ship-it
description: Decide whether a branch can merge, then merge it. Rebases onto the latest base, runs the repo's verification, gives a MERGE or DON'T-MERGE verdict with evidence, then merges the way the repo requires (local squash, or push the branch and open a PR/MR). Use for "can we merge?", "zmerguj", "squash to main", "rebase and merge", "czy można mergować".
---

# Ship it

Follow the repo's own git rules; this skill supplies the order and the evidence.

1. **Conventions.** Read the repo's `AGENTS.md` and the git-workflow doc it points to. Find the verification command (docs, then `package.json` scripts, then CI config) and whether E2E must pass before merge. Ask the user once when none exists. Done when you can name the merge path (local squash into the base, or push the branch and open a PR/MR for review), the verification command, and the E2E policy. Never assume a local merge: when the docs do not say, ask once.
2. **Pre-flight.** Run `git status`, `git fetch`, and compare ahead/behind. Uncommitted work: commit it first when the user asked to ship, otherwise report it. List `git log <base>..HEAD --oneline`. A commit that does not belong to the branch's purpose is a **foreign commit**: typically the branch grew from a parent that `<base>` already contains as a squash.
3. **Rebase.** Rebase onto the latest base (`grefresh` when it exists in the shell; stacked branches use their parent as base). With foreign commits, rebase `--onto <base> <last foreign commit>`: a plain rebase replays them and conflicts on files `<base>` already changed. Resolve mechanical conflicts and name each resolution in the report. Stop on conflicts that need a product decision.
4. **Verify.** Run the verification command, plus E2E when the policy requires it. Record test counts. A failure gets one diagnosis: caused by the branch, or already present on the base (run the failing test on the base in a throwaway worktree prepared with the repo's setup script). Done when each failure has a cause.
5. **Verdict.** Report `MERGE` or `DON'T MERGE` with: behind count, verification result with counts, diff stat against the branch's purpose, foreign commits (none or listed), E2E result.
6. **Merge.** On `MERGE`, follow the merge path from step 1.
   - Local squash: follow the repo's merge doc (one commit, conventional message), push only when the request includes pushing, then report the commit hash on the base and `git log -1 --stat`.
   - PR/MR required: push the branch, open the PR/MR with the repo's tooling, report its URL, and leave the base untouched.

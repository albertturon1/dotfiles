---
name: prove-it
description: Prove a change works by observing it work, with evidence that could have shown failure. Use before reporting a change done, and when the user asks for proof, empirical verification, irrefutable evidence, or an unhappy-path check.
---

# Prove it

Run the steps in order. Each ends on a criterion.

1. **Behavior.** Write each user-visible outcome as one checkable sentence. Done when a stranger could check each sentence.
2. **Surface.** Name where a user observes the outcome (browser page, CLI output, API response, file, agent config) and observe it there. State what the environment cannot reproduce (device hardware, safe-area insets) and name the real route to prove it. Done when every outcome has a surface or a stated gap.
3. **Isolation.** Run against throwaway or local state. Shared or production data stays untouched.
4. **Control.** Show the check can fail: run it before the change, or with the change reverted, and record the failure. For interception or fault tooling, first show the tool bites (the injected failure appears in the request log or output). Done when each outcome has a recorded failure and a recorded pass.
5. **Unhappy paths.** For each network call or input the change touches, exercise: error response, timeout or slow response, offline, empty, unauthorized, malformed. Mark each `PASS`, `FAIL`, or `NOT-COVERED` with the reason. Done when no path is unmarked.
6. **Evidence.** Save artifacts (screenshots, logs, command output) and list absolute paths. Report `PASS`/`FAIL` per outcome. Open at least one artifact yourself before reporting.

A cheap verifier can run steps 2–6: load `delegate` with role `verify`.

Tools, commands, and worked examples: [EXAMPLES.md](EXAMPLES.md).

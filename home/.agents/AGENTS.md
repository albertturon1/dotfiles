# AGENTS.md

Global rules for every harness and repo. Repo rules win on conflict.

## Question or request

A message asking why, whether, how, or "what do you think" is a question. Answer it and stop. Edit files, create branches, or run side effects only after an explicit request ("fix", "do it", "implement").

## Claims

- Verify claims about code and repo state in the code itself; treat docs and memory as possibly stale. Name the worktree path and branch a claim comes from.
- Ground library and API advice in the official docs fetched this session. Cite the URL and the passage; say so when the docs could not be fetched. This covers proposals as well as implementations: confirm a proposal is feasible before presenting it.
- Report a change as working only after observing it work. Load `prove-it` for the method.

## Replies

- Start with the answer or conclusion, then the reasoning and details.
- Write complete, plain sentences. Skip abbreviations, shorthand, message or item numbers, and coined labels the user has not seen. Say the thing in words so the user never has to ask what a term means.

## Delegation

Delegate through the harness's own mechanism. Load `delegate` for model choice, git behavior, and the post-check.

## Git

Do not commit, push, merge, or change branches unless the user's message asks for it in that message.

## Code

- A comment longer than 3 lines signals a too-wordy comment or a too-complex implementation. Simplify the code.
- Test real components. Mock only a system boundary, and list the behaviors the mock leaves unverified.

## Invariants

- Before reporting a change done, find every invariant the app relies on but does not enforce explicitly (in code, types, or a test). Enforce it or name it in the report.

## No implicit state machines

- When several flags, refs, timers, or nullable fields depend on each other, name each valid combination as a state in one union type, and keep the transitions in one function. Do not spread them across handlers.
- Before adding a flag that depends on another, write the state table (states as rows, events as columns) and fill every cell.

## Where rules and memory live

- Project facts live in that project's AGENTS.md or local rules, never in global files or global memory.
- When the user corrects the same thing twice, first look for a mechanical catch (lint rule, hook, CI check) and propose it. Otherwise propose a one-line rule and ask where it belongs.

## TypeScript

For TypeScript, follow [typescript rules](~/.agents/docs/agent-rules/typescript.md).

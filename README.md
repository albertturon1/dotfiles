# Dotfiles

Personal dotfiles for macOS.

## Installation

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Post-Installation

Grant any macOS permissions requested by the installed apps, then restart the
terminal.

## Agent configuration

One file is the source of truth: `home/.agents/AGENTS.md` (global rules for every harness). `./install.sh` stows it to each harness:

| Harness | Global file | Status |
| --- | --- | --- |
| Claude Code | `~/.claude/CLAUDE.md` imports `~/.agents/AGENTS.md` | verified with a canary |
| OpenCode | `~/.config/opencode/AGENTS.md` | verified with a canary |
| Codex | `~/.codex/AGENTS.md` | linked, not verified (default model errored in the test) |
| Cursor | none documented: User Rules live in Settings | run `agents-cursor-rules` and paste |

Cursor reads project rules only from `.cursor/rules/*.mdc` and `AGENTS.md` in the repo. In a repo where personal rules must not be committed, run `agents-local-init` inside each checkout (it writes an untracked, excluded `.cursor/rules/personal.mdc`).

Canary test for a new location: add the line `Start every reply with the marker CANARY-<x>.` to the rules, open a fresh session, ask a neutral question, then remove the line. Run the same question first without the line as the control.

Model tiers for the `delegate` skill live in `home/.agents/models.md`; edit them per machine.

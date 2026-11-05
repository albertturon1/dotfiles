# Examples

Worked cases for [SKILL.md](SKILL.md). Pick the nearest one; adapt the method, not the commands.

## Browser UI (agent-browser)

Run `agent-browser skills get core` first. Observed on agent-browser 0.26.0:

- `network route <url> --abort` works only with the **full URL** (`http://host:port/api/x`). Glob patterns from the help text (`**/api/*`) did not match a `fetch`.
- `network route --body` did not replace the response body in a probe. Confirm in the request log before relying on it.
- Routes take no status code and no delay. Use a server-side fault switch for 500 and slow responses.
- `set offline on` leaves document navigation to the server. Abort the document URL with `network route <document-url> --abort`.
- `network requests --filter api` shows whether the request fired and with what status. Use it as the control.
- Desktop Chrome has no home-indicator inset. Mark device-only layout as `NOT-COVERED` and propose a preview deploy on a real device.

## CLI, shell function, git

Build a throwaway sandbox: a bare repo as `origin`, a clone, fixed author variables, `GIT_CONFIG_GLOBAL=/dev/null`. One scenario per behavior, one assertion per outcome. Control: run the plain command too and show where it fails (`grefresh --fork-point` versus plain `git rebase`).

## API

Run the real server with a local database. Exercise with `curl` per outcome, then repeat with a failing dependency. Save the responses.

## Agent configuration (rules, skills, hooks)

Use a canary: add a rule that makes the agent start its reply with a unique marker, open a fresh session, ask a neutral question. Run once before adding the rule as the control. Use a different marker per location to learn which locations load.

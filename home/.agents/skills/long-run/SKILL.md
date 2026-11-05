---
name: long-run
description: Keep the Mac awake during long unattended work, then release it. Use when the user leaves the computer (overnight, a meeting, "zostawiam to na noc"), says "pracuj aż", "work until it passes", or wants a notification or sleep when the work ends.
---

# Long run

1. **Done criterion.** Write the outcome that ends the run as a checkable condition (for example "local `main` equals `origin/main` and contains the squash"). Set an attempt limit (default 3) for each failing step. Done when both are written down before work starts.
2. **Awake.** Start one `caffeinate -i -t <cap-seconds>` in the background (`-i` blocks idle sleep and leaves the screen lock alone; `-t` is the hard cap, default 8 hours, and releases the assertion even if the agent dies). Save its PID in `$TMPDIR/long-run/<session>.pid`. Verify it: `ps -p <pid> -o command=` shows caffeinate and `pmset -g assertions` lists `PreventUserIdleSystemSleep`. When it fails to start, tell the user and carry on without it. Skip the start when your own PID file shows a live one.
3. **Work.** Track every task that needs the computer: background commands, delegated agents, scheduled children. A task with unknown status counts as running. Silence from a task is not completion.
4. **Release.** Release only when every tracked task is `completed`, `failed`, or `cancelled` and the done criterion is checked. Then:
   - read the PID file, confirm the command is caffeinate, kill that PID only; leave other caffeinate processes alone and mention them if they would keep the Mac awake;
   - run `pmset -g assertions` and confirm your assertion is gone.
5. **Finish.** Send `osascript -e 'display notification "<result>" with title "long-run"'`. Sleep (`pmset sleepnow`) only when the user asked for it in this run, and only after a `completed` outcome. After a failure keep the Mac awake and leave the state for the user.

Closing the lid sleeps a Mac regardless of caffeinate (without AC power and an external display); ask the user to leave it open.

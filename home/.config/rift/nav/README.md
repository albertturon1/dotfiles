# nav

Focus navigation for the Rift window manager, plus the JankyBorders handler that goes with it. Built by `install.sh`
(`go build -o nav .`); `config.toml` calls the binary from its keybindings and from `run_on_start`.

## Commands

| Command | What it does |
|---|---|
| `nav next` / `nav prev` | Move to the next or previous top-level slot (a window or a group). Past either end it jumps straight to the other end. |
| `nav left\|right\|up\|down` | Act only inside a group. Along the group's own direction it stays in the group (side-by-side groups wrap, stacked groups stop at the edge). Outside a group it does nothing. Across the group's axis it falls through to Rift's own move. |
| `nav workspace <index>` | Switch workspace after presetting the borders for the workspace about to be shown. |
| `nav borders` | Event handler: set the borders for the current layout. Rift runs it on every layout or focus event. |

A group is a container that is not the root. A slot is a child of the root.

## Borders

JankyBorders always draws the focused window's border in the active color. Hiding means transparent colors, so the
colors have to be right before focus moves. `next`, `prev` and `workspace` predict the target and set them first.
The handler corrects everything else (mouse, Cmd+Tab). The rule is the one from AeroSpace's `borders-toggle.sh`: hidden
when the focused window sits in a stack or fewer than two windows are visible; floating windows count as visible.

## Quiet window

While `nav` moves focus, Rift also reports the intermediate steps (selecting the group before leaving it) and the
handler would undo the preset. `nav` writes a deadline to `$TMPDIR/rift-nav-quiet`; the handler does nothing until it
passes, and `nav` applies the final state itself. `quiet.go` holds all of it.

## What the tests do not cover

The tests exercise the decision logic on built trees, `queryState` against a stand-in `rift-cli` script, and the quiet
file on real temporary files. Not verified by any test: the Mach message to JankyBorders (`ipc_darwin.go`), the real
`rift-cli` and its asynchronous focus changes (`waitForChange`, `step`), `applyBorders` starting JankyBorders, and the
physical key presses. Those were checked by hand: pixel colors on screenshots, flash frames on screen recordings of
Ghostty and Zed windows. Spotify and Helium were not tried. `rift-cli` and `borders` are looked up in `/opt/homebrew/bin` and `/usr/local/bin`, then on PATH (rift starts nav with a minimal PATH).

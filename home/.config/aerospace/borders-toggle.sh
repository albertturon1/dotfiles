#!/bin/bash
# Toggle JankyBorders based on explicit AeroSpace state.
#
# Decision table (row = parent layout of the focused window, column = number
# of windows visible on the screen of the focused workspace):
#
#   layout of focused window | 1 visible | 2+ visible
#   -------------------------+-----------+-----------
#   (no focused window)      |   HIDE    |   HIDE
#   accordion (h or v)       |   HIDE    |   HIDE
#   floating                 |   HIDE    |   SHOW
#   tiles (h or v)           |   HIDE    |   SHOW
#
# "visible" counts what is really on screen: every floating window plus every
# tiling window, except that an accordion root always shows exactly one
# tiling window no matter how many windows it stacks.
#
# Usage:
#   borders-toggle.sh                 decide SHOW or HIDE (AeroSpace callbacks, skhd layout bindings)
#   borders-toggle.sh go <args...>    hide borders, then run `aerospace <args...>` (skhd workspace bindings)

# Feature switch for this machine/profile. Set to "no" to disable the whole
# feature: borders are never started and a running instance is killed.
ENABLED=yes

BORDERS_ARGS='style=round width=6.0 active_color=0xff00ff00 inactive_color=0xff494d64'
# Both colors must be transparent: inactive_color applies to every unfocused window.
HIDDEN_ARGS='active_color=0x00000000 inactive_color=0x00000000'

if [ "${1:-}" = go ]; then
    shift
    # Hide only a running instance. Calling borders with arguments when none runs
    # starts it in the foreground and blocks the caller.
    pgrep -x borders >/dev/null && borders $HIDDEN_ARGS
    exec aerospace "$@"
fi

if [ "$ENABLED" != yes ]; then
    killall borders 2>/dev/null
    exit 0
fi

# Start the borders process if it is not running yet (e.g. after AeroSpace startup).
if ! pgrep -x borders >/dev/null; then
    borders $BORDERS_ARGS &
    sleep 0.3
fi

rows=$(aerospace list-windows --workspace focused --format '%{window-layout} %{workspace-root-container-layout}' 2>/dev/null)
focused_layout=$(aerospace list-windows --focused --format '%{window-layout}' 2>/dev/null)

count=0 floating=0 root_layout=
if [ -n "$rows" ]; then
    while read -r layout root; do
        count=$(( count + 1 ))
        [ "$layout" = floating ] && floating=$(( floating + 1 ))
        root_layout=${root_layout:-$root}
    done <<< "$rows"
fi
tiling=$(( count - floating ))

case "$root_layout" in
    *_accordion) visible=$(( floating + 1 )) ;;
    *) visible=$(( floating + tiling )) ;;
esac

case "$focused_layout" in
    *_accordion) show=no ;;
    floating|*_tiles) [ "$visible" -ge 2 ] && show=yes || show=no ;;
    *) show=no ;;
esac

if [ "$show" = yes ]; then
    borders $BORDERS_ARGS
else
    borders $HIDDEN_ARGS
fi

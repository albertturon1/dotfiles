#!/usr/bin/python3 -I
"""Put the listed workspaces in accordion (stack) layout once rift has started.

Rift's own `stack` layout mode flattens the tree and ignores join_window, so this turns the root of a
traditional workspace into a stack instead (the same as toggle_stack), which keeps groups working.
"""
import json
import subprocess
import time

RIFT = "/opt/homebrew/bin/rift-cli"
STACK_WORKSPACES = ("Q", "W")


def query(*args):
    out = subprocess.run([RIFT, "query", *args], capture_output=True, text=True).stdout
    return json.loads(out)


def run(*args):
    subprocess.run([RIFT, "execute", *args], capture_output=True)
    time.sleep(0.4)


def wait_for_rift():
    for _ in range(60):
        try:
            return query("workspaces")
        except (json.JSONDecodeError, OSError):
            time.sleep(0.5)
    raise SystemExit(0)


def selected_is_root(tree):
    return tree["is_selected"]


def make_stack(index):
    tree = query("layout", "--workspace-id", str(index))["container_tree"]
    if (tree["layout_kind"] or "").endswith("_stack"):
        return
    run("workspace", "switch", str(index))
    for _ in range(4):
        if selected_is_root(query("layout")["container_tree"]):
            break
        run("layout", "ascend")
    run("layout", "toggle-stack")
    run("layout", "descend")


def main():
    workspaces = wait_for_rift()
    original = next((w["index"] for w in workspaces if w["is_active"]), None)
    targets = [w["index"] for w in workspaces if w["name"] in STACK_WORKSPACES]
    for index in targets:
        if index != original:
            make_stack(index)
    if original is not None and original in targets:
        make_stack(original)
    active = next((w["index"] for w in query("workspaces") if w["is_active"]), None)
    if original is not None and active != original:
        run("workspace", "switch", str(original))


if __name__ == "__main__":
    main()

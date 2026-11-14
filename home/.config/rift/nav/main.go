// nav: focus navigation for rift that understands groups, plus the JankyBorders handler that goes with it.
// Usage: nav next|prev|left|right|up|down | nav workspace <index> | nav borders (rules and design: README.md).
package main

import (
	"encoding/json"
	"errors"
	"os"
	"os/exec"
	"path/filepath"
	"time"
)

// rift is a variable so tests can point it at a stand-in for the real command line client.
var rift = findTool("rift-cli")

const (
	pollInterval = 10 * time.Millisecond
	waitLimit    = 800 * time.Millisecond
)

var errNoLayout = errors.New("rift returned no layout tree")

// toolDirs are where Homebrew puts tools; rift starts nav with a minimal PATH that does not include them.
var toolDirs = []string{"/opt/homebrew/bin", "/usr/local/bin"}

func findTool(name string) string { return findToolIn(toolDirs, name) }

func findToolIn(dirs []string, name string) string {
	for _, dir := range dirs {
		path := filepath.Join(dir, name)
		if info, err := os.Stat(path); err == nil && !info.IsDir() && info.Mode()&0o111 != 0 {
			return path
		}
	}
	if path, err := exec.LookPath(name); err == nil {
		return path
	}
	return filepath.Join(dirs[0], name)
}

func queryState(workspace string) (State, error) {
	args := []string{"query", "layout"}
	if workspace != "" {
		args = append(args, "--workspace-id", workspace)
	}
	out, err := exec.Command(rift, args...).Output()
	if err != nil {
		return State{}, err
	}
	var st State
	if err := json.Unmarshal(out, &st); err != nil {
		return State{}, err
	}
	if st.Tree == nil {
		return State{}, errNoLayout
	}
	return st, nil
}

func layout() (*Node, error) {
	st, err := queryState("")
	return st.Tree, err
}

// snapshot is what "focus moved" means: the tree's selected node or the window rift reports as focused changed.
// Both are needed: focusing a floating window leaves the tree's selection where it was.
type snapshot struct {
	node    int64
	focused WindowID
}

func takeSnapshot() (snapshot, bool) {
	st, err := queryState("")
	if err != nil {
		return snapshot{}, false
	}
	path := pathToSelected(st.Tree, nil)
	if path == nil {
		return snapshot{}, false
	}
	s := snapshot{node: path[len(path)-1].NodeID}
	if st.Focused != nil {
		s.focused = *st.Focused
	}
	return s, true
}

func run(args ...string) {
	_ = exec.Command(rift, append([]string{"execute"}, args...)...).Run()
}

func waitForChange(before snapshot) bool {
	for deadline := time.Now().Add(waitLimit); time.Now().Before(deadline); {
		time.Sleep(pollInterval)
		if now, ok := takeSnapshot(); ok && now != before {
			return true
		}
	}
	return false
}

func focusWindow(w *WindowID) bool {
	if w == nil {
		return false
	}
	before, _ := takeSnapshot()
	arg, _ := json.Marshal(w)
	run("window", "focus", "--window-id", string(arg))
	return waitForChange(before)
}

func selectTopLevel() bool {
	root, err := layout()
	if err != nil {
		return false
	}
	path := pathToSelected(root, nil)
	if len(path) <= 2 {
		return true
	}
	before, _ := takeSnapshot()
	run("layout", "ascend")
	return waitForChange(before)
}

func step(dir string) bool {
	if !selectTopLevel() {
		return false
	}
	before, _ := takeSnapshot()
	run("window", "focus", dir)
	return waitForChange(before)
}

func cycle(st State, cmd string) {
	root := st.Tree
	plan := planCycle(st, cmd)
	if plan.Kind == "" {
		return
	}
	var target *WindowID
	if plan.Kind == "float" {
		target = plan.Window
	} else {
		target = firstWindow(root.Children[plan.Target])
	}
	beginQuiet()
	presetBorders(showAfterFocus(st, target))
	defer finishBorders()
	switch plan.Kind {
	case "step":
		step(plan.Dir)
	case "float":
		focusWindow(plan.Window)
	case "enter":
		slot := root.Children[plan.Target]
		if slot.NodeType == "window" || plan.Neighbor < 0 {
			focusWindow(firstWindow(slot))
		} else if focusWindow(firstWindow(root.Children[plan.Neighbor])) {
			step(plan.Dir)
		}
	case "jump":
		slot := root.Children[plan.Target]
		if slot.NodeType == "window" {
			focusWindow(slot.WindowID)
			return
		}
		dir := "right"
		if axisOf(root) == 'v' {
			dir = "down"
		}
		if plan.Target == 0 {
			dir = "left"
			if axisOf(root) == 'v' {
				dir = "up"
			}
		}
		path := pathToSelected(root, nil)
		if len(path) < 2 {
			return
		}
		if root.Children[plan.Neighbor].NodeID == path[1].NodeID || focusWindow(firstWindow(root.Children[plan.Neighbor])) {
			step(dir)
		}
	}
}

// finishBorders applies the borders for where focus really ended up, then stays quiet a moment for late events.
func finishBorders() {
	endQuiet()
	refreshBorders()
}

// switchWorkspace presets the borders for the workspace about to be shown, then switches to it.
func switchWorkspace(index string) {
	st, err := queryState(index)
	if err == nil && !st.IsActive {
		var target *WindowID
		if path := pathToSelected(st.Tree, nil); path != nil {
			if last := path[len(path)-1]; last.NodeType == "window" {
				target = last.WindowID
			} else if len(last.Children) > 0 {
				target = firstWindow(last)
			}
		}
		if target == nil && len(st.Tree.Children) > 0 {
			target = firstWindow(st.Tree)
		}
		presetBorders(showAfterFocus(st, target))
	}
	run("workspace", "switch", index)
}

// descendToWindow handles a container being selected (for example right after toggle_stack).
func descendToWindow(root *Node) *Node {
	for i := 0; i < 8; i++ {
		path := pathToSelected(root, nil)
		if len(path) == 0 {
			return root
		}
		last := path[len(path)-1]
		if last.NodeType == "window" || len(last.Children) == 0 {
			return root
		}
		before, _ := takeSnapshot()
		run("layout", "descend")
		if !waitForChange(before) {
			return root
		}
		next, err := layout()
		if err != nil {
			return root
		}
		root = next
	}
	return root
}

func main() {
	cmd := "next"
	if len(os.Args) > 1 {
		cmd = os.Args[1]
	}
	switch cmd {
	case "workspace":
		if len(os.Args) > 2 {
			switchWorkspace(os.Args[2])
		}
		return
	case "borders":
		if !isQuiet() {
			refreshBorders()
		}
		return
	}
	st, err := queryState("")
	if err != nil {
		return
	}
	st.Tree = descendToWindow(st.Tree)
	switch cmd {
	case "left", "right", "up", "down":
		if focusIsFloating(st) {
			return // a floating window is never in a group
		}
		switch decideMove(st.Tree, cmd) {
		case Native:
			run("window", "focus", cmd)
		case WrapGroup:
			path := pathToSelected(st.Tree, nil)
			if len(path) < 3 {
				return
			}
			group := path[len(path)-2]
			child := group.Children[0]
			if cmd == "left" {
				child = group.Children[len(group.Children)-1]
			}
			focusWindow(firstWindow(child))
		}
	case "next", "prev":
		cycle(st, cmd)
	}
}

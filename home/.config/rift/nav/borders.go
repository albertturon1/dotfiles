package main

import (
	"os/exec"
	"strings"
	"syscall"
	"time"
)

var bordersBin = findTool("borders")

var (
	shownArgs  = []string{"style=round", "width=8.0", "active_color=0xff4fa84f", "inactive_color=0x00000000"}
	hiddenArgs = []string{"active_color=0x00000000", "inactive_color=0x00000000"}
)

// State is what the border decision needs from `rift-cli query layout`.
type State struct {
	Tree     *Node      `json:"container_tree"`
	Floating []WindowID `json:"floating_windows"`
	Focused  *WindowID  `json:"focused_window"`
	IsActive bool       `json:"is_active_workspace"`
}

func isStack(n *Node) bool {
	return n.LayoutKind != nil && strings.HasSuffix(*n.LayoutKind, "_stack")
}

func containsSelected(n *Node) bool {
	if n.IsSelected {
		return true
	}
	for _, c := range n.Children {
		if containsSelected(c) {
			return true
		}
	}
	return false
}

// visibleIn counts the windows that are really on screen inside a node: a stack shows only its selected child.
func visibleIn(n *Node) int {
	if n.NodeType == "window" {
		return 1
	}
	if len(n.Children) == 0 {
		return 0
	}
	if isStack(n) {
		for _, c := range n.Children {
			if containsSelected(c) {
				return visibleIn(c)
			}
		}
		return visibleIn(n.Children[0])
	}
	total := 0
	for _, c := range n.Children {
		total += visibleIn(c)
	}
	return total
}

func parentOf(root *Node, id WindowID) *Node {
	for _, c := range root.Children {
		if c.NodeType == "window" && c.WindowID != nil && *c.WindowID == id {
			return root
		}
		if p := parentOf(c, id); p != nil {
			return p
		}
	}
	return nil
}

// shouldShow ports borders-toggle.sh from the AeroSpace setup: borders are hidden when the focused window sits
// in an accordion (stack) or when fewer than two windows are visible; floating windows always count as visible.
func shouldShow(s State) bool {
	if s.Focused == nil || s.Tree == nil {
		return false
	}
	visible := len(s.Floating) + visibleIn(s.Tree)
	for _, f := range s.Floating {
		if f == *s.Focused {
			return visible >= 2
		}
	}
	parent := parentOf(s.Tree, *s.Focused)
	if parent == nil || isStack(parent) {
		return false
	}
	return visible >= 2
}

func cloneNode(n *Node) *Node {
	c := *n
	c.Children = make([]*Node, len(n.Children))
	for i, child := range n.Children {
		c.Children[i] = cloneNode(child)
	}
	return &c
}

// showAfterFocus predicts shouldShow once focus has moved to the target window, without touching the state.
func showAfterFocus(s State, target *WindowID) bool {
	tree := cloneNode(s.Tree)
	var mark func(n *Node)
	mark = func(n *Node) {
		n.IsSelected = n.NodeType == "window" && n.WindowID != nil && target != nil && *n.WindowID == *target
		for _, c := range n.Children {
			mark(c)
		}
	}
	mark(tree)
	return shouldShow(State{Tree: tree, Floating: s.Floating, Focused: target})
}

func bordersArgs(show bool) []string {
	if show {
		return shownArgs
	}
	return hiddenArgs
}

// presetBorders sets the borders before a focus change so the new window never gets the old color. It never
// blocks: if JankyBorders does not answer, the event handler fixes things afterwards.
func presetBorders(show bool) {
	sendBorders(bordersArgs(show))
}

// startBorders launches JankyBorders detached; running it with arguments in the foreground would block.
func startBorders() {
	cmd := exec.Command(bordersBin, shownArgs...)
	cmd.SysProcAttr = &syscall.SysProcAttr{Setsid: true}
	if cmd.Start() == nil {
		_ = cmd.Process.Release()
	}
}

// applyBorders is the event handler's version: it also starts JankyBorders when it is not running.
func applyBorders(show bool) {
	args := bordersArgs(show)
	rc := sendBorders(args)
	if rc == ipcOK {
		return
	}
	if rc == ipcNotRunning {
		startBorders()
		for i := 0; i < 40; i++ {
			time.Sleep(20 * time.Millisecond)
			if sendBorders(args) == ipcOK {
				return
			}
		}
		return
	}
	// The registered instance did not accept the message; fall back to the command line client.
	_ = exec.Command(bordersBin, args...).Run()
}

// refreshBorders sets the borders for the layout rift reports right now.
func refreshBorders() {
	if st, err := queryState(""); err == nil {
		applyBorders(shouldShow(st))
	}
}

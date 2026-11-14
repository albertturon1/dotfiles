package main

import "strings"

// Node is one entry of the tree that `rift-cli query layout` returns.
type Node struct {
	NodeID     int64     `json:"node_id"`
	NodeType   string    `json:"node_type"`
	Children   []*Node   `json:"children"`
	IsSelected bool      `json:"is_selected"`
	LayoutKind *string   `json:"layout_kind"`
	WindowID   *WindowID `json:"window_id"`

	tag string // test helper label, never set by JSON decoding
}

type WindowID struct {
	Idx int64 `json:"idx"`
	Pid int64 `json:"pid"`
}

type MoveAction string

const (
	Native    MoveAction = "native"
	Stay      MoveAction = "stay"
	WrapGroup MoveAction = "wrap-group"
)

type CyclePlan struct {
	Kind     string    // "", "step", "jump", "float" or "enter"
	Dir      string    // step and enter: direction towards the target slot
	Target   int       // step, jump, enter: top-level slot to land on
	Neighbor int       // jump, enter: slot next to the target, used to enter a group; -1 when there is none
	Window   *WindowID // float: the floating window to focus
}

func pathToSelected(n *Node, trail []*Node) []*Node {
	trail = append(append([]*Node{}, trail...), n)
	if n.IsSelected {
		return trail
	}
	for _, c := range n.Children {
		if p := pathToSelected(c, trail); p != nil {
			return p
		}
	}
	return nil
}

// firstWindow returns the first window under n, or nil when n holds none.
func firstWindow(n *Node) *WindowID {
	for n.NodeType != "window" {
		if len(n.Children) == 0 {
			return nil
		}
		n = n.Children[0]
	}
	return n.WindowID
}

func axisOf(c *Node) byte {
	if c.LayoutKind != nil && strings.HasPrefix(*c.LayoutKind, "vertical") {
		return 'v'
	}
	return 'h'
}

func indexOf(children []*Node, id int64) int {
	for i, c := range children {
		if c.NodeID == id {
			return i
		}
	}
	return -1
}

// decideMove answers a left/right/up/down press. Outside a group nothing moves; inside a group a move along the
// group's own direction stays in the group (side-by-side groups wrap, stacked groups stop at the edge).
func decideMove(root *Node, dir string) MoveAction {
	path := pathToSelected(root, nil)
	if len(path) < 2 {
		return Native
	}
	if len(path) == 2 {
		return Stay
	}
	sideways := dir == "left" || dir == "right"
	forward := dir == "right" || dir == "down"
	group := path[len(path)-2]
	want := byte('v')
	if sideways {
		want = 'h'
	}
	if axisOf(group) != want {
		return Native
	}
	i := indexOf(group.Children, path[len(path)-1].NodeID)
	atEdge := i == 0
	if forward {
		atEdge = i == len(group.Children)-1
	}
	if !atEdge {
		return Native
	}
	if sideways {
		return WrapGroup
	}
	return Stay
}

// focusIsFloating reports whether rift's focused window is one of the floating windows. The tree's own selection
// does not follow focus to a floating window, so it cannot be used to tell where focus is.
func focusIsFloating(st State) bool {
	if st.Focused == nil {
		return false
	}
	for _, f := range st.Floating {
		if f == *st.Focused {
			return true
		}
	}
	return false
}

// currentItem numbers the things next|prev walk over: the top-level slots, then the floating windows.
// It returns -1 when nothing is focused.
func currentItem(st State) int {
	tiled := len(st.Tree.Children)
	if st.Focused != nil {
		for i, f := range st.Floating {
			if f == *st.Focused {
				return tiled + i
			}
		}
	}
	path := pathToSelected(st.Tree, nil)
	if len(path) < 2 {
		return -1
	}
	return indexOf(st.Tree.Children, path[1].NodeID)
}

// planCycle decides how to reach the next or previous item: top-level slots in tree order, then floating windows,
// wrapping from the last item to the first.
func planCycle(st State, cmd string) CyclePlan {
	root := st.Tree
	tiled := len(root.Children)
	total := tiled + len(st.Floating)
	cur := currentItem(st)
	if total < 2 || cur < 0 {
		return CyclePlan{}
	}
	delta := 1
	if cmd != "next" {
		delta = -1
	}
	target := (cur + delta + total) % total
	forward, backward := "right", "left"
	if axisOf(root) == 'v' {
		forward, backward = "down", "up"
	}
	if target >= tiled {
		return CyclePlan{Kind: "float", Window: &st.Floating[target-tiled]}
	}
	if cur >= tiled {
		neighbor, dir := target-1, forward
		if target == 0 {
			neighbor, dir = 1, backward
		}
		if neighbor < 0 || neighbor >= tiled {
			neighbor = -1
		}
		return CyclePlan{Kind: "enter", Dir: dir, Target: target, Neighbor: neighbor}
	}
	if target == cur+1 {
		return CyclePlan{Kind: "step", Dir: forward, Target: target}
	}
	if target == cur-1 {
		return CyclePlan{Kind: "step", Dir: backward, Target: target}
	}
	if target == 0 {
		return CyclePlan{Kind: "jump", Target: 0, Neighbor: 1}
	}
	return CyclePlan{Kind: "jump", Target: target, Neighbor: target - 1}
}

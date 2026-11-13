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
	Kind     string // "", "step" or "jump"
	Dir      string // for "step"
	Target   int    // top-level index to land on
	Neighbor int    // for "jump": top-level index next to the target
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

func planCycle(root *Node, cmd string) CyclePlan {
	path := pathToSelected(root, nil)
	count := len(root.Children)
	if len(path) < 2 || count < 2 {
		return CyclePlan{}
	}
	i := indexOf(root.Children, path[1].NodeID)
	forward, backward := "right", "left"
	if axisOf(root) == 'v' {
		forward, backward = "down", "up"
	}
	if cmd == "next" {
		if i < count-1 {
			return CyclePlan{Kind: "step", Dir: forward, Target: i + 1}
		}
		return CyclePlan{Kind: "jump", Target: 0, Neighbor: 1}
	}
	if i > 0 {
		return CyclePlan{Kind: "step", Dir: backward, Target: i - 1}
	}
	return CyclePlan{Kind: "jump", Target: count - 1, Neighbor: count - 2}
}

package main

import "testing"

var nextID int64

func win(name string) *Node {
	nextID++
	return &Node{NodeID: nextID, NodeType: "window", WindowID: &WindowID{Idx: nextID, Pid: 1}, tag: name}
}

func box(kind string, kids ...*Node) *Node {
	nextID++
	return &Node{NodeID: nextID, NodeType: "container", LayoutKind: &kind, Children: kids, tag: kind}
}

func selectNamed(root *Node, name string) *Node {
	var walk func(n *Node)
	walk = func(n *Node) {
		n.IsSelected = n.tag == name
		for _, c := range n.Children {
			walk(c)
		}
	}
	walk(root)
	return root
}

func TestDecideMove(t *testing.T) {
	stack := box("horizontal_stack", win("A"), box("horizontal", win("B"), win("C"), win("D")), win("E"), box("horizontal", win("F"), win("G")))
	cases := []struct {
		sel, dir string
		want     MoveAction
	}{
		{"B", "left", WrapGroup}, {"C", "left", Native}, {"D", "right", WrapGroup}, {"C", "right", Native},
		{"A", "left", Stay}, {"A", "right", Stay}, {"E", "right", Stay}, {"F", "left", WrapGroup},
		{"G", "right", WrapGroup}, {"A", "up", Stay}, {"B", "up", Native}, {"B", "down", Native},
	}
	for _, c := range cases {
		if got := decideMove(selectNamed(stack, c.sel), c.dir); got != c.want {
			t.Errorf("%s %s: got %s want %s", c.sel, c.dir, got, c.want)
		}
	}

	split := box("horizontal", win("A"), win("B"), win("C"))
	for _, s := range []string{"A", "B", "C"} {
		for _, d := range []string{"left", "right"} {
			if got := decideMove(selectNamed(split, s), d); got != Stay {
				t.Errorf("split %s %s: got %s want stay", s, d, got)
			}
		}
	}
	beside := box("horizontal", win("A"), box("horizontal", win("B"), win("C")))
	if got := decideMove(selectNamed(beside, "A"), "right"); got != Stay {
		t.Errorf("window beside group right: got %s want stay", got)
	}

	vertical := box("horizontal", win("A"), box("vertical", win("B"), win("C"), win("D")), win("E"))
	for _, c := range []struct {
		sel, dir string
		want     MoveAction
	}{{"B", "up", Stay}, {"C", "up", Native}, {"D", "down", Stay}, {"C", "down", Native}, {"B", "left", Native}, {"D", "right", Native}} {
		if got := decideMove(selectNamed(vertical, c.sel), c.dir); got != c.want {
			t.Errorf("vertical group %s %s: got %s want %s", c.sel, c.dir, got, c.want)
		}
	}
	hGroup := box("horizontal", win("A"), box("horizontal", win("B"), win("C")))
	if got := decideMove(selectNamed(hGroup, "B"), "left"); got != WrapGroup {
		t.Errorf("horizontal group B left: got %s", got)
	}
	if got := decideMove(selectNamed(hGroup, "B"), "up"); got != Native {
		t.Errorf("horizontal group B up: got %s", got)
	}
}

func tiledOnly(root *Node) State { return State{Tree: root} }

func TestPlanCycle(t *testing.T) {
	r := box("horizontal_stack", win("A"), box("horizontal", win("B"), win("C"), win("D")), win("E"), box("horizontal", win("F"), win("G")))
	cases := []struct {
		sel, cmd string
		want     CyclePlan
	}{
		{"A", "next", CyclePlan{Kind: "step", Dir: "right", Target: 1}},
		{"C", "next", CyclePlan{Kind: "step", Dir: "right", Target: 2}},
		{"G", "next", CyclePlan{Kind: "jump", Target: 0, Neighbor: 1}},
		{"A", "prev", CyclePlan{Kind: "jump", Target: 3, Neighbor: 2}},
		{"E", "prev", CyclePlan{Kind: "step", Dir: "left", Target: 1}},
	}
	for _, c := range cases {
		if got := planCycle(tiledOnly(selectNamed(r, c.sel)), c.cmd); got != c.want {
			t.Errorf("%s %s: got %+v want %+v", c.sel, c.cmd, got, c.want)
		}
	}
	two := box("horizontal", win("A"), win("B"))
	// With two slots the wrap target is the neighbour, so a plain step is enough.
	if got := planCycle(tiledOnly(selectNamed(two, "B")), "next"); got != (CyclePlan{Kind: "step", Dir: "left", Target: 0}) {
		t.Errorf("two items wrap: %+v", got)
	}
	if got := planCycle(tiledOnly(selectNamed(box("horizontal", win("A")), "A")), "next"); got.Kind != "" {
		t.Errorf("single: %+v", got)
	}
	if got := planCycle(tiledOnly(box("horizontal")), "next"); got.Kind != "" {
		t.Errorf("empty: %+v", got)
	}
	v := box("vertical", win("A"), win("B"), win("C"))
	if got := planCycle(tiledOnly(selectNamed(v, "A")), "next"); got != (CyclePlan{Kind: "step", Dir: "down", Target: 1}) {
		t.Errorf("vertical root: %+v", got)
	}
	if got := planCycle(tiledOnly(selectNamed(v, "C")), "next"); got != (CyclePlan{Kind: "jump", Target: 0, Neighbor: 1}) {
		t.Errorf("vertical wrap: %+v", got)
	}
}

func TestPlanCycleWithFloatingWindows(t *testing.T) {
	f1, f2 := WindowID{Idx: 901, Pid: 1}, WindowID{Idx: 902, Pid: 1}
	one := func() (*Node, State) {
		root := box("horizontal", win("A"))
		return root, State{Tree: selectNamed(root, "A"), Floating: []WindowID{f1}}
	}
	// One tiled window and one floating window: backtick must switch between them (the case from workspace S).
	_, st := one()
	if got := planCycle(st, "next"); got.Kind != "float" || *got.Window != f1 {
		t.Errorf("tiled -> floating: %+v", got)
	}
	st.Focused = &f1
	if got := planCycle(st, "next"); got.Kind != "enter" || got.Target != 0 || got.Neighbor != -1 {
		t.Errorf("floating -> the only tiled slot: %+v", got)
	}

	// Two tiled windows and one floating: tiled order first, then the floating window, then back to the first slot.
	build := func() State {
		root := box("horizontal_stack", win("A"), win("B"))
		return State{Tree: root, Floating: []WindowID{f1}}
	}
	st = build()
	selectNamed(st.Tree, "B")
	if got := planCycle(st, "next"); got.Kind != "float" || *got.Window != f1 {
		t.Errorf("last tiled slot next: %+v", got)
	}
	selectNamed(st.Tree, "A")
	if got := planCycle(st, "prev"); got.Kind != "float" || *got.Window != f1 {
		t.Errorf("first tiled slot prev: %+v", got)
	}
	st.Focused = &f1
	if got := planCycle(st, "next"); got.Kind != "enter" || got.Target != 0 || got.Neighbor != 1 || got.Dir != "left" {
		t.Errorf("floating next enters slot 0 from slot 1: %+v", got)
	}
	if got := planCycle(st, "prev"); got.Kind != "enter" || got.Target != 1 || got.Neighbor != 0 || got.Dir != "right" {
		t.Errorf("floating prev enters slot 1 from slot 0: %+v", got)
	}

	// Floating windows only reach each other; with no tiled windows they cycle among themselves.
	empty := State{Tree: box("horizontal"), Floating: []WindowID{f1, f2}, Focused: &f1}
	if got := planCycle(empty, "next"); got.Kind != "float" || *got.Window != f2 {
		t.Errorf("floating -> floating: %+v", got)
	}
	empty.Focused = &f2
	if got := planCycle(empty, "next"); got.Kind != "float" || *got.Window != f1 {
		t.Errorf("floating wrap: %+v", got)
	}
	// A focused floating window the tree does not know must not be confused with the tree's selection.
	root := box("horizontal", win("A"), win("B"))
	both := State{Tree: selectNamed(root, "A"), Floating: []WindowID{f1}, Focused: &f1}
	if got := planCycle(both, "next"); got.Kind != "enter" || got.Target != 0 {
		t.Errorf("focus on the floating window wins over the tree selection: %+v", got)
	}
	// Nothing focused anywhere: do nothing.
	if got := planCycle(State{Tree: box("horizontal", win("A"), win("B")), Floating: []WindowID{f1}}, "next"); got.Kind != "" {
		t.Errorf("nothing selected: %+v", got)
	}
}

func TestFocusIsFloating(t *testing.T) {
	f := WindowID{Idx: 901, Pid: 1}
	tiled := WindowID{Idx: 5, Pid: 1}
	st := State{Tree: box("horizontal"), Floating: []WindowID{f}}
	if focusIsFloating(st) {
		t.Error("nothing focused is not floating")
	}
	st.Focused = &tiled
	if focusIsFloating(st) {
		t.Error("a tiled focus is not floating")
	}
	st.Focused = &f
	if !focusIsFloating(st) {
		t.Error("focus on a floating window must be recognised")
	}
}

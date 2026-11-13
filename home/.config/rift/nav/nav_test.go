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
		if got := planCycle(selectNamed(r, c.sel), c.cmd); got != c.want {
			t.Errorf("%s %s: got %+v want %+v", c.sel, c.cmd, got, c.want)
		}
	}
	two := box("horizontal", win("A"), win("B"))
	if got := planCycle(selectNamed(two, "B"), "next"); got != (CyclePlan{Kind: "jump", Target: 0, Neighbor: 1}) {
		t.Errorf("two items wrap: %+v", got)
	}
	if got := planCycle(selectNamed(box("horizontal", win("A")), "A"), "next"); got.Kind != "" {
		t.Errorf("single: %+v", got)
	}
	if got := planCycle(box("horizontal"), "next"); got.Kind != "" {
		t.Errorf("empty: %+v", got)
	}
	v := box("vertical", win("A"), win("B"), win("C"))
	if got := planCycle(selectNamed(v, "A"), "next"); got != (CyclePlan{Kind: "step", Dir: "down", Target: 1}) {
		t.Errorf("vertical root: %+v", got)
	}
	if got := planCycle(selectNamed(v, "C"), "next"); got != (CyclePlan{Kind: "jump", Target: 0, Neighbor: 1}) {
		t.Errorf("vertical wrap: %+v", got)
	}
}

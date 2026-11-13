package main

import "testing"

func focusOn(root *Node, target *Node) State {
	var mark func(n *Node)
	mark = func(n *Node) {
		n.IsSelected = n == target
		for _, c := range n.Children {
			mark(c)
		}
	}
	mark(root)
	return State{Tree: root, Focused: target.WindowID}
}

func TestShouldShow(t *testing.T) {
	cases := []struct {
		name  string
		build func() State
		want  bool
	}{
		{"single tiled window", func() State { a := win("a"); return focusOn(box("horizontal", a), a) }, false},
		{"two windows side by side", func() State { a, b := win("a"), win("b"); return focusOn(box("horizontal", a, b), a) }, true},
		{"three windows side by side", func() State { a, b, c := win("a"), win("b"), win("c"); return focusOn(box("horizontal", a, b, c), c) }, true},
		{"stack of two windows", func() State { a, b := win("a"), win("b"); return focusOn(box("horizontal_stack", a, b), a) }, false},
		{"stack of three windows", func() State {
			a, b, c := win("a"), win("b"), win("c")
			return focusOn(box("horizontal_stack", a, b, c), b)
		}, false},
		{"group of two in a stack, focus in group", func() State {
			g1, g2, o := win("g1"), win("g2"), win("o")
			return focusOn(box("horizontal_stack", o, box("horizontal", g1, g2)), g1)
		}, true},
		{"stack with a group, focus on the lone window", func() State {
			g1, g2, o := win("g1"), win("g2"), win("o")
			return focusOn(box("horizontal_stack", o, box("horizontal", g1, g2)), o)
		}, false},
		{"stack group inside a split shows one window per slot", func() State {
			s1, s2, s3 := win("s1"), win("s2"), win("s3")
			return focusOn(box("horizontal", s3, box("horizontal_stack", s1, s2)), s1)
		}, false},
		{"one tiled window plus a floating one, focus tiled", func() State {
			a, f := win("a"), win("f")
			s := focusOn(box("horizontal", a), a)
			s.Floating = []WindowID{*f.WindowID}
			return s
		}, true},
		{"only a floating window", func() State {
			f := win("f")
			return State{Tree: box("horizontal"), Floating: []WindowID{*f.WindowID}, Focused: f.WindowID}
		}, false},
		{"floating focused with a tiled window behind", func() State {
			a, f := win("a"), win("f")
			s := focusOn(box("horizontal", a), a)
			s.Floating = []WindowID{*f.WindowID}
			s.Focused = f.WindowID
			return s
		}, true},
		{"nothing focused", func() State { a, b := win("a"), win("b"); return State{Tree: box("horizontal", a, b)} }, false},
		{"empty workspace", func() State { return State{Tree: box("horizontal")} }, false},
	}
	for _, c := range cases {
		if got := shouldShow(c.build()); got != c.want {
			t.Errorf("%s: got %v want %v", c.name, got, c.want)
		}
	}
}

// The prediction must agree with what shouldShow says once focus really is on the target.
func TestShowAfterFocus(t *testing.T) {
	zed, g1, g2 := win("zed"), win("g1"), win("g2")
	group := box("horizontal", g1, g2)
	root := box("horizontal_stack", zed, group)
	st := focusOn(root, g1) // currently inside the group: borders shown

	if !shouldShow(st) {
		t.Fatal("precondition: borders should show inside the group")
	}
	if showAfterFocus(st, zed.WindowID) {
		t.Error("moving from the group to the lone stack slot must hide borders")
	}
	if !showAfterFocus(st, g2.WindowID) {
		t.Error("moving inside the group must keep borders")
	}
	if !shouldShow(st) {
		t.Error("prediction must not change the state it was given")
	}

	flat := box("horizontal", win("a"), win("b"), win("c"))
	flatState := focusOn(flat, flat.Children[0])
	if !showAfterFocus(flatState, flat.Children[2].WindowID) {
		t.Error("moving between split windows keeps borders")
	}
	if showAfterFocus(flatState, nil) {
		t.Error("an empty target hides borders")
	}
}

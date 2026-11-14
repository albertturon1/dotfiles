package main

import (
	"os"
	"path/filepath"
	"testing"
)

// fakeRift stands in for rift-cli, the system boundary: it prints a fixed reply and exits with the given status.
func fakeRift(t *testing.T, reply string, status string) {
	t.Helper()
	script := filepath.Join(t.TempDir(), "rift-cli")
	body := "#!/bin/sh\ncat <<'EOF'\n" + reply + "\nEOF\nexit " + status + "\n"
	if err := os.WriteFile(script, []byte(body), 0o755); err != nil {
		t.Fatal(err)
	}
	old := rift
	rift = script
	t.Cleanup(func() { rift = old })
}

const goodReply = `{"container_tree":{"node_id":1,"node_type":"container","layout_kind":"horizontal_stack","is_selected":false,
"children":[{"node_id":2,"node_type":"window","is_selected":true,"children":[],"window_id":{"idx":7,"pid":9}}]},
"floating_windows":[{"idx":3,"pid":4}],"focused_window":{"idx":7,"pid":9},"is_active_workspace":true}`

func TestQueryState(t *testing.T) {
	fakeRift(t, goodReply, "0")
	st, err := queryState("")
	if err != nil {
		t.Fatalf("good reply: %v", err)
	}
	if len(st.Tree.Children) != 1 || len(st.Floating) != 1 || st.Focused == nil || !st.IsActive {
		t.Errorf("good reply parsed wrongly: %+v", st)
	}

	fakeRift(t, `{"container_tree":null,"floating_windows":[]}`, "0")
	if _, err := queryState(""); err != errNoLayout {
		t.Errorf("null tree: got %v, want errNoLayout", err)
	}
	fakeRift(t, "not json at all", "0")
	if _, err := queryState(""); err == nil {
		t.Error("garbage reply must be an error")
	}
	fakeRift(t, goodReply, "1")
	if _, err := queryState(""); err == nil {
		t.Error("a failing client must be an error")
	}
	rift = filepath.Join(t.TempDir(), "missing")
	if _, err := queryState(""); err == nil {
		t.Error("a missing client must be an error")
	}
}

func TestFirstWindowOfEmptyContainer(t *testing.T) {
	if got := firstWindow(box("horizontal")); got != nil {
		t.Errorf("empty container: got %+v, want nil", got)
	}
	w := win("w")
	if got := firstWindow(box("horizontal", box("horizontal"), w)); got != nil {
		t.Errorf("first child is empty: got %+v, want nil (only the first path is followed)", got)
	}
	if got := firstWindow(box("horizontal", w)); got == nil || *got != *w.WindowID {
		t.Errorf("single window: got %+v", got)
	}
}

func TestFindToolIn(t *testing.T) {
	first, second := t.TempDir(), t.TempDir()
	write := func(dir, name string, mode os.FileMode) string {
		p := filepath.Join(dir, name)
		if err := os.WriteFile(p, []byte("#!/bin/sh\n"), mode); err != nil {
			t.Fatal(err)
		}
		return p
	}
	write(first, "tool", 0o644) // present but not executable: must be skipped
	want := write(second, "tool", 0o755)
	if got := findToolIn([]string{first, second}, "tool"); got != want {
		t.Errorf("got %s, want the executable in the second directory %s", got, want)
	}
	if got := findToolIn([]string{first, second}, "no-such-tool-anywhere"); got != filepath.Join(first, "no-such-tool-anywhere") {
		t.Errorf("an unknown tool falls back to the first directory, got %s", got)
	}
}

func TestSnapshotSeesFocusMovingToAFloatingWindow(t *testing.T) {
	tree := `{"container_tree":{"node_id":1,"node_type":"container","layout_kind":"horizontal","is_selected":false,"children":[{"node_id":2,"node_type":"window","is_selected":true,"children":[],"window_id":{"idx":7,"pid":9}}]},"floating_windows":[{"idx":3,"pid":4}],`
	fakeRift(t, tree+`"focused_window":{"idx":7,"pid":9}}`, "0")
	tiledFocus, ok := takeSnapshot()
	if !ok {
		t.Fatal("no snapshot")
	}
	fakeRift(t, tree+`"focused_window":{"idx":3,"pid":4}}`, "0")
	floatFocus, _ := takeSnapshot()
	if floatFocus == tiledFocus {
		t.Error("focus moved to the floating window but the tree selection did not: snapshots must still differ")
	}
}

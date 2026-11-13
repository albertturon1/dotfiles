package main

import (
	"os"
	"strconv"
	"testing"
	"time"
)

func TestQuietWindow(t *testing.T) {
	t.Setenv("TMPDIR", t.TempDir())

	if isQuiet() {
		t.Fatal("no file yet: must not be quiet")
	}
	beginQuiet()
	if !isQuiet() {
		t.Error("after beginQuiet the handler must be quiet")
	}
	endQuiet()
	if !isQuiet() {
		t.Error("the tail after endQuiet must still be quiet")
	}
	// An expired deadline, garbage and an empty file all mean "not quiet".
	for name, content := range map[string]string{
		"expired": strconv.FormatInt(time.Now().Add(-time.Second).UnixMilli(), 10),
		"garbage": "soon",
		"empty":   "",
	} {
		if err := os.WriteFile(quietFile(), []byte(content), 0o644); err != nil {
			t.Fatal(err)
		}
		if isQuiet() {
			t.Errorf("%s deadline must not be quiet", name)
		}
	}
}

func TestQuietExpires(t *testing.T) {
	t.Setenv("TMPDIR", t.TempDir())
	quietUntil(30 * time.Millisecond)
	if !isQuiet() {
		t.Fatal("must be quiet right after quietUntil")
	}
	time.Sleep(60 * time.Millisecond)
	if isQuiet() {
		t.Error("the quiet window must end by itself")
	}
}

package main

import (
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

// While nav moves focus the event handler stays silent (README, "Quiet window"): beginQuiet covers the whole move,
// endQuiet leaves a short tail for a late event. isQuiet is the only reader.
const (
	moveQuiet = 2 * time.Second
	tailQuiet = 250 * time.Millisecond
)

func quietFile() string { return filepath.Join(os.TempDir(), "rift-nav-quiet") }

func quietUntil(d time.Duration) {
	deadline := time.Now().Add(d).UnixMilli()
	_ = os.WriteFile(quietFile(), []byte(strconv.FormatInt(deadline, 10)), 0o644)
}

func beginQuiet() { quietUntil(moveQuiet) }
func endQuiet()   { quietUntil(tailQuiet) }

func isQuiet() bool {
	data, err := os.ReadFile(quietFile())
	if err != nil {
		return false
	}
	deadline, err := strconv.ParseInt(strings.TrimSpace(string(data)), 10, 64)
	return err == nil && time.Now().UnixMilli() < deadline
}

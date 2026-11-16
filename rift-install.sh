#!/bin/bash
# Installs our Rift fork: downloads the binaries published for the commit pinned in vendor/rift (GitHub release
# `build-<12 character sha>` of the fork), checks their checksum, installs them into ~/.local/bin and (re)starts the
# launchd agent. Needs no Rust. Apple Silicon only.
# With RIFT_BINARY_DIR=<dir holding rift-fork and rift-cli> it installs those instead and touches neither the network
# nor the submodule (rift-dev.sh uses this for local builds).
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
AGENT="$HOME/Library/LaunchAgents/git.acsandmann.rift.plist"
ASSET="rift-fork-macos-arm64.tar.gz"

[[ "$(uname -m)" == arm64 ]] || { echo 'rift-install: the prebuilt fork is Apple Silicon only' >&2; exit 1; }
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
if [[ -n "${RIFT_BINARY_DIR:-}" ]]; then
    cp "$RIFT_BINARY_DIR/rift-fork" "$RIFT_BINARY_DIR/rift-cli" "$tmp/"
else
    # The commit the dotfiles pin (their committed submodule pointer) and the fork's URL; neither needs the submodule
    # to be checked out, so a plain clone of the dotfiles is enough and a working copy in vendor/rift is never touched.
    sha="$(git -C "$DOTFILES_DIR" ls-tree HEAD vendor/rift | awk '{print substr($3,1,12)}')"
    repo="$(git config -f "$DOTFILES_DIR/.gitmodules" --get submodule.vendor/rift.url)"
    repo="${repo%.git}"
    [[ -n "$sha" && -n "$repo" ]] || { echo 'rift-install: vendor/rift is not a submodule of these dotfiles' >&2; exit 1; }
    base="$repo/releases/download/build-$sha"
    echo "Downloading the Rift fork build-$sha ..."
    curl -fsSL -o "$tmp/$ASSET" "$base/$ASSET"
    curl -fsSL -o "$tmp/$ASSET.sha256" "$base/$ASSET.sha256"
    (cd "$tmp" && shasum -a 256 -c "$ASSET.sha256")
    tar -xzf "$tmp/$ASSET" -C "$tmp"
    if [[ "${RIFT_INSTALL_DRY_RUN:-}" == 1 ]]; then
        echo "Dry run: downloaded and verified build-$sha, nothing installed."
        file "$tmp/rift-fork" "$tmp/rift-cli"
        exit 0
    fi
fi

mkdir -p "$BIN_DIR"
changed=0
for name in rift-fork rift-cli; do
    if ! cmp -s "$tmp/$name" "$BIN_DIR/$name" 2>/dev/null; then
        install -m 755 "$tmp/$name" "$BIN_DIR/$name.new"
        mv -f "$BIN_DIR/$name.new" "$BIN_DIR/$name"
        [[ "$name" == rift-fork ]] && changed=1
    fi
done

mkdir -p "$HOME/Library/LaunchAgents"
cat > "$tmp/agent.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>git.acsandmann.rift</string>
    <key>ProgramArguments</key><array><string>$BIN_DIR/rift-fork</string></array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key><string>$BIN_DIR:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
        <key>RUST_LOG</key><string>error,warn,info</string>
    </dict>
    <key>RunAtLoad</key><true/>
    <key>KeepAlive</key><dict><key>SuccessfulExit</key><false/><key>Crashed</key><true/></dict>
    <key>StandardOutPath</key><string>/tmp/rift_fork.out.log</string>
    <key>StandardErrorPath</key><string>/tmp/rift_fork.err.log</string>
    <key>ProcessType</key><string>Interactive</string>
    <key>LimitLoadToSessionType</key><string>Aqua</string>
    <key>Nice</key><integer>-20</integer>
</dict>
</plist>
PLIST
if [[ $changed -eq 1 ]] || ! cmp -s "$tmp/agent.plist" "$AGENT" 2>/dev/null; then
    cp "$tmp/agent.plist" "$AGENT"
    launchctl bootout "gui/$(id -u)/git.acsandmann.rift" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$AGENT"
    echo 'Rift fork started.'
else
    echo 'Rift fork is already up to date.'
fi
echo 'If Rift reports a missing permission: System Settings > Privacy & Security > Accessibility > enable rift-fork (once for this binary).'

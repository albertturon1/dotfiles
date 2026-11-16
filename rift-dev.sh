#!/bin/bash
# Development helper for our Rift fork, the submodule vendor/rift (branch `dotfiles`: ONE commit on top of upstream).
#
#   rift-dev.sh build     build, sign with the local certificate (if there is one), install and restart Rift
#   rift-dev.sh test      run the fork's tests
#   rift-dev.sh update    rebase the fork's commit onto the latest upstream main and run the tests
#   rift-dev.sh publish   build and upload the binaries as the release `build-<sha>` of the fork (what rift-install.sh
#                         downloads); the fork's branch has to be pushed first
#   rift-dev.sh ship      push the branch, publish, and stage the new submodule pointer (you commit it)
#   rift-dev.sh cert      create the local signing certificate once (it keeps the Accessibility permission across builds)
#
# Keep the fork a single commit: `git -C vendor/rift commit --amend` after a change, never a second commit. That makes
# the rebase in `update` one conflict resolution at most.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORK_DIR="$DOTFILES_DIR/vendor/rift"
CERT_NAME="Rift Fork Local Signing"
IDENTIFIER="local.rift-fork"
BRANCH="dotfiles"

fork() { git -C "$FORK_DIR" "$@"; }

need_branch() {
    [[ "$(fork branch --show-current)" == "$BRANCH" ]] || { echo "vendor/rift is not on the $BRANCH branch (git -C vendor/rift checkout $BRANCH)" >&2; exit 1; }
}

# Build the binaries into $1 (rift-fork, rift-cli), signed when the certificate exists.
build_into() {
    local out="$1"
    (cd "$FORK_DIR" && cargo build --release --bin rift --bin rift-cli)
    cp "$FORK_DIR/target/release/rift" "$out/rift-fork"
    cp "$FORK_DIR/target/release/rift-cli" "$out/rift-cli"
    if security find-identity -p codesigning 2>/dev/null | grep -q "$CERT_NAME"; then
        codesign --force -s "$CERT_NAME" -i "$IDENTIFIER" "$out/rift-fork"
    else
        echo "No signing certificate ($CERT_NAME): the binary keeps its ad-hoc signature, so Accessibility must be granted again after each build. Run: rift-dev.sh cert"
    fi
}

cmd_build() {
    local stage; stage="$(mktemp -d)"
    trap 'rm -rf "$stage"' RETURN
    build_into "$stage"
    RIFT_BINARY_DIR="$stage" "$DOTFILES_DIR/rift-install.sh"
}

cmd_test() { (cd "$FORK_DIR" && cargo test --lib); }

cmd_update() {
    need_branch
    [[ -z "$(fork status --porcelain)" ]] || { echo 'vendor/rift has uncommitted changes: amend them into the commit first' >&2; exit 1; }
    fork remote get-url upstream >/dev/null 2>&1 || fork remote add upstream https://github.com/acsandmann/rift.git
    fork fetch upstream
    echo "Upstream main is $(fork rev-list --count HEAD..upstream/main) commits ahead of the fork."
    if ! fork rebase upstream/main; then
        echo 'Rebase stopped on a conflict. Fix it, `git -C vendor/rift add <files> && git -C vendor/rift rebase --continue`, then run this again.' >&2
        exit 1
    fi
    cmd_test
    echo 'Rebased and tested. Next: rift-dev.sh build (try it), then rift-dev.sh ship.'
}

cmd_publish() {
    need_branch
    [[ -z "$(fork status --porcelain)" ]] || { echo 'vendor/rift has uncommitted changes' >&2; exit 1; }
    local full sha repo asset stage
    full="$(fork rev-parse HEAD)"; sha="${full:0:12}"
    [[ "$(fork ls-remote origin "refs/heads/$BRANCH" | cut -f1)" == "$full" ]] || { echo "The $BRANCH branch is not pushed to origin at this commit (git -C vendor/rift push --force-with-lease origin $BRANCH)" >&2; exit 1; }
    repo="$(fork remote get-url origin)"; repo="${repo%.git}"; repo="${repo#https://github.com/}"
    asset="rift-fork-macos-arm64.tar.gz"
    stage="$(mktemp -d)"; trap 'rm -rf "$stage"' RETURN
    build_into "$stage"
    (cd "$stage" && tar -czf "$asset" rift-fork rift-cli && shasum -a 256 "$asset" > "$asset.sha256")
    gh release delete "build-$sha" --repo "$repo" --yes --cleanup-tag >/dev/null 2>&1 || true
    gh release create "build-$sha" "$stage/$asset" "$stage/$asset.sha256" --repo "$repo" --target "$full" \
        --title "build-$sha" --notes "Binaries built on the developer's Mac from $full: rift-fork (the window manager) and rift-cli."
    echo "Published build-$sha."
}

cmd_ship() {
    need_branch
    fork push --force-with-lease origin "$BRANCH"
    cmd_publish
    git -C "$DOTFILES_DIR" add vendor/rift
    echo "Staged the new vendor/rift pointer in the dotfiles. Commit it: git commit -m 'chore(rift): update the fork'"
}

cmd_cert() {
    if security find-identity -p codesigning 2>/dev/null | grep -q "$CERT_NAME"; then echo "Certificate '$CERT_NAME' already exists."; return; fi
    local dir pw; dir="$(mktemp -d)"; pw="$(openssl rand -hex 12)"; trap 'rm -rf "$dir"' RETURN
    cat > "$dir/cert.cnf" <<'CNF'
[req]
distinguished_name = dn
x509_extensions = ext
prompt = no
[dn]
CN = Rift Fork Local Signing
[ext]
basicConstraints = critical,CA:false
keyUsage = critical,digitalSignature
extendedKeyUsage = critical,codeSigning
CNF
    openssl req -x509 -newkey rsa:2048 -nodes -keyout "$dir/key.pem" -out "$dir/cert.pem" -days 3650 -config "$dir/cert.cnf" 2>/dev/null
    openssl pkcs12 -export -inkey "$dir/key.pem" -in "$dir/cert.pem" -out "$dir/rift.p12" -passout "pass:$pw" -name "$CERT_NAME" \
        -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -macalg sha1
    security import "$dir/rift.p12" -k "$HOME/Library/Keychains/login.keychain-db" -P "$pw" -T /usr/bin/codesign
    echo "Created '$CERT_NAME' in the login keychain."
}

case "${1:-help}" in
    build) cmd_build ;;
    test) cmd_test ;;
    update) cmd_update ;;
    publish) cmd_publish ;;
    ship) cmd_ship ;;
    cert) cmd_cert ;;
    *) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//' ;;
esac

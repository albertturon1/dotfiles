#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_TOOLS_DIR="$DOTFILES_DIR/home/.pi/agent/extensions/web-tools"
COMPLETED=""
SKIPPED=""
FAILED=""

summary() {
    local status="$1"
    printf '\nCompleted:%s\nSkipped:%s\nFailed:%s\n' \
        "${COMPLETED:- none}" "${SKIPPED:- none}" "${FAILED:- none}"
    if [[ "$status" != 0 ]]; then
        echo "Finished with errors; earlier changes have not been rolled back."
    fi
}

fail() {
    FAILED+=$'\n  - '"$1"
    echo "Error: $1" >&2
    return 1
}

check_tools() {
    local tool missing=false
    [[ "$(uname -s)" == Darwin ]] || { fail 'macOS is required'; return 1; }
    [[ -f "$DOTFILES_DIR/Brewfile" ]] || { fail 'Brewfile is missing'; return 1; }
    for tool in "$@"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            fail "Required command is missing: $tool" || true
            missing=true
        fi
    done
    [[ "$missing" == false ]]
}

ensure_homebrew() {
    local installer brew_path shellenv
    if ! command -v brew >/dev/null 2>&1; then
        if [[ -x /opt/homebrew/bin/brew ]]; then
            brew_path=/opt/homebrew/bin/brew
        elif [[ -x /usr/local/bin/brew ]]; then
            brew_path=/usr/local/bin/brew
        else
            echo 'Installing Homebrew...'
            installer="$(mktemp)" || return 1
            if ! curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$installer"; then
                rm -f "$installer"
                fail 'Could not download the Homebrew installer'; return 1
            fi
            if ! /bin/bash "$installer"; then
                rm -f "$installer"
                fail 'Homebrew installation failed'; return 1
            fi
            rm -f "$installer" || return 1
            if [[ -x /opt/homebrew/bin/brew ]]; then
                brew_path=/opt/homebrew/bin/brew
            else
                brew_path=/usr/local/bin/brew
            fi
            COMPLETED+=$'\n  - Homebrew installed'
        fi
        shellenv="$("$brew_path" shellenv)" || return 1
        eval "$shellenv" || return 1
        local line="eval \"\$(\"$brew_path\" shellenv)\""
        if ! grep -qF "$line" "$HOME/.zprofile" 2>/dev/null; then
            printf '\n%s\n' "$line" >> "$HOME/.zprofile" || return 1
        fi
    else
        SKIPPED+=$'\n  - Homebrew already available'
    fi
    if ! command -v stow >/dev/null 2>&1; then
        # Stow is needed to check conflicts before installing other packages.
        brew install stow || { fail 'Could not install Stow for conflict checking'; return 1; }
        COMPLETED+=$'\n  - Stow installed'
    fi
    check_tools brew stow
}

stow_dotfiles() {
    if [[ "$1" == check ]]; then
        stow --simulate --ignore=node_modules --dir="$DOTFILES_DIR" -t "$HOME" home
    else
        stow -R --ignore=node_modules --dir="$DOTFILES_DIR" -t "$HOME" home
    fi
}

install_packages() {
    echo 'Installing missing Brewfile packages...'
    brew bundle --no-upgrade --file="$DOTFILES_DIR/Brewfile" || return 1
    check_tools stow skhd aerospace || return 1
    if [[ -f "$WEB_TOOLS_DIR/package.json" ]]; then check_tools node npm || return 1; fi
}

configure_shell_and_git() {
    local line='source ~/.zsh/shared.zsh' current
    if grep -qF "$line" "$HOME/.zshrc" 2>/dev/null; then
        SKIPPED+=$'\n  - Shell configuration already loaded'
    else
        printf '\n# Load shared dotfiles configuration\n%s\n' "$line" >> "$HOME/.zshrc" || return 1
        COMPLETED+=$'\n  - Shell configuration added'
    fi
    current="$(git config --global --get core.excludesfile || true)"
    if [[ "$current" == "$HOME/.gitignore_global" ]]; then
        SKIPPED+=$'\n  - Git ignore configuration already set'
    elif [[ -n "$current" ]]; then
        echo "Keeping existing Git excludesfile: $current"
        SKIPPED+=$'\n  - Existing Git ignore configuration preserved'
    else
        git config --global core.excludesfile "$HOME/.gitignore_global" || return 1
        COMPLETED+=$'\n  - Git ignore configuration added'
    fi
}

install_fff() {
    local installer
    if command -v fff-mcp >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/fff-mcp" ]]; then
        SKIPPED+=$'\n  - FFF MCP already installed'
        return 0
    fi
    installer="$(mktemp)" || return 1
    if ! curl -fsSL https://dmtrkovalenko.dev/install-fff-mcp.sh -o "$installer"; then
        rm -f "$installer"
        return 1
    fi
    if ! bash "$installer"; then
        rm -f "$installer"
        return 1
    fi
    rm -f "$installer" || return 1
    command -v fff-mcp >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/fff-mcp" ]] || return 1
    COMPLETED+=$'\n  - FFF MCP installed'
}

skhd_is_ready() {
    [[ "$1" =~ Daemon\ running:[[:space:]]+Yes ]] &&
    [[ "$1" =~ Hotkeys\ functional:[[:space:]]+Yes ]] &&
    [[ ! "$1" =~ Input\ Monitoring:[[:space:]]+Denied ]]
}

start_services() {
    local status attempt
    status="$(skhd --status 2>&1)" || status=""
    if skhd_is_ready "$status"; then
        SKIPPED+=$'\n  - skhd already running'
    elif skhd --start-service; then
        for attempt in 1 2 3 4 5; do
            sleep 1
            status="$(skhd --status 2>&1)" || status=""
            skhd_is_ready "$status" && break
        done
        if skhd_is_ready "$status"; then
            COMPLETED+=$'\n  - skhd started'
        else
            fail 'skhd is not ready; see its status below' || true
            printf '%s\n' "$status"
        fi
    else
        fail 'Could not start the skhd service' || true
    fi
    # Autostart is configured in .aerospace.toml.
    if open -a AeroSpace; then
        COMPLETED+=$'\n  - AeroSpace launch requested'
    else
        fail 'Could not launch AeroSpace' || true
    fi
}

main() {
    local mode="${1:-install}"
    if [[ "$#" -gt 1 ]]; then echo 'Usage: ./install.sh [install|check|update]' >&2; return 1; fi
    case "$mode" in
        -h|--help) echo 'Usage: ./install.sh [install|check|update]'; return 0 ;;
        install|check|update) ;;
        *) echo 'Usage: ./install.sh [install|check|update]' >&2; return 1 ;;
    esac
    trap 'summary "$?"' EXIT
    if [[ "$mode" == update ]]; then
        check_tools brew || return 1
        brew bundle --file="$DOTFILES_DIR/Brewfile" || { fail 'Brewfile update failed'; return 1; }
        COMPLETED+=$'\n  - Brewfile packages updated'
        return 0
    fi
    check_tools git curl || return 1
    if [[ "$mode" == check ]]; then
        check_tools brew stow || return 1
    else
        ensure_homebrew || { fail 'Dependency bootstrap failed'; return 1; }
    fi
    stow_dotfiles check || { fail 'Dotfile conflicts detected; configuration was not linked'; return 1; }
    COMPLETED+=$'\n  - Dotfiles checked for conflicts'
    if [[ "$mode" == check ]]; then
        check_tools skhd aerospace || return 1
        if [[ -f "$WEB_TOOLS_DIR/package.json" ]]; then check_tools node npm || return 1; fi
        HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --no-upgrade --file="$DOTFILES_DIR/Brewfile" || { fail 'Brewfile dependency check failed; inspect the Homebrew output'; return 1; }
        COMPLETED+=$'\n  - Dependencies checked; no installation performed'
        return 0
    fi
    install_packages || { fail 'Package installation or required command check failed'; return 1; }
    COMPLETED+=$'\n  - Brewfile packages available'
    stow_dotfiles install || { fail 'Could not link dotfiles'; return 1; }
    COMPLETED+=$'\n  - Dotfiles linked'
    if [[ -f "$WEB_TOOLS_DIR/package.json" ]]; then
        npm install --prefix "$WEB_TOOLS_DIR" --omit=dev --no-package-lock --ignore-scripts || { fail 'Pi web-tools dependency installation failed'; return 1; }
        COMPLETED+=$'\n  - Pi web-tools dependencies installed'
    else
        SKIPPED+=$'\n  - Pi web-tools not present'
    fi
    configure_shell_and_git || { fail 'Shell or Git configuration failed'; return 1; }
    install_fff || fail 'FFF MCP installation failed' || true
    start_services
    echo 'Restart your terminal to load shell configuration.'
    [[ -z "$FAILED" ]]
}

main "$@"

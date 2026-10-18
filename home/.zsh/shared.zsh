#!/bin/zsh
# Shared zsh configuration for all machines
# This file is sourced by ~/.zshrc on each machine

# Add dotfiles bin to PATH for tools
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

alias lg="lazygit"
alias nv='nvim .'
alias oc='opencode'
alias ocp='opencode --port'

# Stop the process listening on a TCP port (for example: killport 3000).
killport() {
  if (( $# != 1 )) || [[ ! $1 =~ '^[0-9]+$' ]] || (( $1 < 1 || $1 > 65535 )); then
    echo "Usage: killport <port (1-65535)>" >&2
    return 2
  fi

  local port="$1"
  local pids
  local lsof_status
  pids=(${(f)$(lsof -ti "tcp:$port" -sTCP:LISTEN 2>/dev/null)})
  lsof_status=$?

  if (( ${#pids[@]} == 0 )); then
    if (( lsof_status != 0 )); then
      echo "killport: failed to inspect port $port (lsof exited with status $lsof_status)" >&2
    else
      echo "killport: no process is listening on port $port" >&2
    fi
    return 1
  fi

  if kill $pids 2>/dev/null; then
    echo "Stopped process(es) on port $port."
  else
    local kill_status=$?
    echo "killport: failed to stop process(es) on port $port (kill exited with status $kill_status)" >&2
    return "$kill_status"
  fi
}

# Editor
export EDITOR=nvim

# XDG directories
export XDG_CONFIG_HOME="$HOME/.config"

# Initialize completions
autoload -Uz compinit
compinit

prompt_dir_2() {
  local dir="${PWD/#$HOME/~}"
  local parts hidden
  parts=(${(s:/:)dir})

  if (( ${#parts[@]} > 2 )); then
    hidden=$((${#parts[@]} - 2))
    print -r -- "…[$hidden]/${parts[-2]}/${parts[-1]}"
  else
    print -r -- "$dir"
  fi
}

PROMPT='%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ ) %{$fg[cyan]%}$(prompt_dir_2)%{$reset_color%} $(git_prompt_info)'

# Opencode + cmux integration
# Requires: cmux (https://github.com/ocmux/cmux) and opencode CLI

# Open opencode in a new surface (new tab) within current workspace
oct() {
  local output surface

  output=$(cmux new-surface 2>&1) || { echo "oct: failed to create surface" >&2; return 1 }
  [[ "$output" =~ "surface:"([0-9]+) ]] && surface="surface:${match[1]}"
  [[ -z $surface ]] && { echo "oct: could not parse surface ID" >&2; return 1 }

  cmux move-surface --surface "$surface" --focus true >/dev/null
  cmux send --surface "$surface" $'opencode\n' >/dev/null

  echo "${fg[green]}✓ Created new tab${reset_color}"
}

# Open opencode in a new workspace with dedicated surface
ocw() {
  local output workspace

  output=$(cmux new-workspace --name "oc-$(date +%s)" --command "opencode --port" 2>&1) || {
    echo "ocw: failed to create workspace" >&2; return 1
  }

  [[ "$output" =~ "workspace:"([0-9]+) ]] && workspace="workspace:${match[1]}"
  [[ -z $workspace ]] && { echo "ocw: could not parse workspace ID" >&2; return 1 }

  cmux select-workspace --workspace "$workspace" >/dev/null 2>&1

  echo "${fg[green]}✓ Created new workspace${reset_color}"
}

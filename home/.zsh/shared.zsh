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

# Rebase the current branch onto the latest base branch (stack-aware).
# Usage: grefresh [base-branch]
#   Without an argument the base is the remote's default branch (main/master/...),
#   resolved from refs/remotes/origin/HEAD.
#   For stacked PRs pass the parent branch: grefresh feature/parent
#   Local changes are stashed and restored by git itself (--autostash), including
#   after a conflict once you run `git rebase --continue` or `git rebase --abort`.
grefresh() {
  local remote base base_ref branch

  if (( $# > 1 )) || [[ "${1-}" == -* ]]; then
    echo "Usage: grefresh [base-branch]" >&2
    return 2
  fi

  git rev-parse --git-dir >/dev/null 2>&1 || {
    echo "grefresh: not inside a git repository" >&2
    return 1
  }

  branch=$(git symbolic-ref --short -q HEAD) || {
    echo "grefresh: detached HEAD, check out a branch first" >&2
    return 1
  }

  remote=$(git config --get "branch.$branch.remote") || remote=origin
  git remote get-url "$remote" >/dev/null 2>&1 || {
    echo "grefresh: remote '$remote' does not exist" >&2
    return 1
  }

  if [[ -n "${1-}" ]]; then
    base="${1}"
  else
    base_ref=$(git symbolic-ref -q "refs/remotes/$remote/HEAD") || {
      echo "grefresh: cannot determine default branch of $remote; run 'git remote set-head $remote -a' or pass the base branch" >&2
      return 1
    }
    base="${base_ref#refs/remotes/$remote/}"
  fi

  if [[ "$base" == "$branch" ]]; then
    echo "grefresh: you are on '$base' itself; pass the parent branch of your stack or run it from a feature branch" >&2
    return 1
  fi

  git fetch --prune --quiet "$remote" || {
    echo "grefresh: fetch from $remote failed" >&2
    return 1
  }

  git show-ref --verify --quiet "refs/remotes/$remote/$base" || {
    echo "grefresh: $remote/$base does not exist" >&2
    return 1
  }

  if git merge-base --is-ancestor "refs/remotes/$remote/$base" HEAD; then
    echo "grefresh: $branch already contains $remote/$base, nothing to do"
    return 0
  fi

  # --fork-point uses the reflog of origin/<base> to find where the branch really
  # forked, so a rewritten (amended/squashed + force-pushed) parent does not
  # replay its old commits. Falls back to the merge-base when there is no reflog.
  # --autostash stashes local changes and re-applies them when the rebase finishes
  # (or is aborted), so no manual stash/pop is needed.
  if ! git rebase --autostash --fork-point "refs/remotes/$remote/$base"; then
    echo "grefresh: rebase of $branch onto $remote/$base stopped with conflicts." >&2
    echo "  fix the files, then: git add <files> && git rebase --continue" >&2
    echo "  or to undo everything: git rebase --abort" >&2
    echo "  (your local changes are restored automatically in both cases)" >&2
    return 1
  fi

  echo "grefresh: $branch rebased onto $remote/$base"
}

# Print the global agent rules for pasting into Cursor
# (Settings > Customize > Rules > User Rules). Cursor documents no file path for them.
# Usage: agents-cursor-rules   (also copies to the clipboard)
agents-cursor-rules() {
  local source="$HOME/.agents/AGENTS.md"
  [[ -f "$source" ]] || { echo "agents-cursor-rules: $source not found" >&2; return 1; }
  cat "$source"
  pbcopy < "$source" && echo "agents-cursor-rules: copied to clipboard" >&2
}

# Add personal agent rules to the current repo without committing them:
# a Cursor project rule (.cursor/rules/personal.mdc, alwaysApply) excluded through
# the repo's info/exclude, which applies to every worktree of the clone.
# Usage: agents-local-init [rules-file]   (default: ~/.agents/AGENTS.md)
agents-local-init() {
  local source="${1:-$HOME/.agents/AGENTS.md}" root exclude
  [[ -f "$source" ]] || { echo "agents-local-init: $source not found" >&2; return 1; }
  root="$(git rev-parse --show-toplevel 2>/dev/null)" ||
    { echo "agents-local-init: not inside a git repository" >&2; return 1; }
  exclude="$(git -C "$root" rev-parse --path-format=absolute --git-path info/exclude)" || return 1
  mkdir -p "$root/.cursor/rules" "$(dirname "$exclude")" || return 1
  {
    printf -- '---\ndescription: Personal agent rules\nalwaysApply: true\n---\n\n'
    cat "$source"
  } > "$root/.cursor/rules/personal.mdc" || return 1
  grep -qxF '/.cursor/rules/personal.mdc' "$exclude" 2>/dev/null ||
    printf '/.cursor/rules/personal.mdc\n' >> "$exclude" || return 1
  echo "Wrote $root/.cursor/rules/personal.mdc (excluded via $exclude)"
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

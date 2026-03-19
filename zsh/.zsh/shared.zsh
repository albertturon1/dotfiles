#!/bin/zsh
# Shared zsh configuration for all machines
# This file is sourced by ~/.zshrc on each machine

# Add dotfiles bin to PATH for tools like xws
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Editor
export EDITOR=nvim

# XDG directories
export XDG_CONFIG_HOME="$HOME/.config"

# Enable completions from dotfiles
fpath+=("$HOME/.zsh/completions")

# Initialize completions
autoload -Uz compinit
compinit

zstyle ':completion:*:*:xws:*' insert-unambiguous false

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

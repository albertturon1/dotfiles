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

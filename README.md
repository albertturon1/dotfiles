# Dotfiles

Personal dotfiles managed with GNU Stow.

## Prerequisites

- macOS
- Homebrew

## Installation

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

## What's Included

- **aerospace** - i3-like tiling window manager for macOS
- **agents** - Global AI coding-agent instructions (`~/.agents/AGENTS.md`, mirrored for Pi at `~/.pi/agent/AGENTS.md`)
- **skhd** - Hotkey daemon (skhd.zig fork)
- **nvim** - Neovim configuration (kickstart.nvim based)
- **zsh** - Shell configuration
- **lazygit** - Git TUI
- **opencode** - OpenCode AI assistant config
- **pi** - Pi coding agent extensions
- **fff-mcp** - MCP server for file navigation used by OpenCode

## Updating Neovim Kickstart

`nvim/.config/nvim` is a Git subtree of `nvim-lua/kickstart.nvim`. Keep personal configuration in `nvim/.config/nvim/lua/custom/`; the only intended upstream edits are the `require 'custom'` import and the Nerd Font setting in `init.lua`.

To import a newer Kickstart version:

```bash
cd ~/dotfiles
git fetch kickstart
git subtree pull --prefix=nvim/.config/nvim kickstart master --squash
stow -R --no-folding -t ~ nvim
```

After resolving any conflicts, update plugins inside Neovim with `:lua vim.pack.update()` and commit the resulting `nvim-pack-lock.json`.

## Post-Installation

1. **Accessibility Permissions** - If skhd shows permission warning:
   - System Settings → Privacy & Security → Accessibility
   - Add `/opt/homebrew/bin/skhd`
   - Run: `skhd --restart-service`

2. **Restart terminal** or run: `source ~/.zshrc`

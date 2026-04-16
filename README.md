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
- **skhd** - Hotkey daemon (skhd.zig fork)
- **nvim** - Neovim configuration (kickstart.nvim based)
- **zsh** - Shell configuration
- **lazygit** - Git TUI
- **opencode** - OpenCode AI assistant config
- **fff-mcp** - MCP server for file navigation used by OpenCode

## Post-Installation

1. **Accessibility Permissions** - If skhd shows permission warning:
   - System Settings → Privacy & Security → Accessibility
   - Add `/opt/homebrew/bin/skhd`
   - Run: `skhd --restart-service`

2. **Restart terminal** or run: `source ~/.zshrc`

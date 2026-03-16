#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

echo "Setting up dotfiles from $DOTFILES_DIR..."

# Check if Homebrew is installed, install if not
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs (idempotent)
    if [[ -f /opt/homebrew/bin/brew ]]; then
        HOMEBREW_LINE='eval "$(/opt/homebrew/bin/brew shellenv)"'
        if ! grep -qF "$HOMEBREW_LINE" ~/.zprofile 2>/dev/null; then
            echo "$HOMEBREW_LINE" >> ~/.zprofile
            echo "Added Homebrew to ~/.zprofile"
        fi
        eval "$HOMEBREW_LINE"
    fi
fi

# Install packages from Brewfile (ignore errors for already installed packages)
echo "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile" --no-upgrade || true

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "Error: GNU Stow is not installed."
    exit 1
fi

# Stow all packages using --adopt to take over existing files
echo "Stowing all packages..."

for package in aerospace bin lazygit nvim opencode skhd tmux zsh; do
    if [ -d "$package" ]; then
        echo "Stowing $package..."
        stow -v --adopt --no-folding -t ~ "$package"
    fi
done

# Install TPM (Tmux Plugin Manager) if not present
if [ -f "$HOME/.config/tmux/tmux.conf" ]; then
    TPM_PATH="$HOME/.config/tmux/plugins/tpm"
    if [ ! -d "$TPM_PATH" ]; then
        echo "Installing TPM (Tmux Plugin Manager)..."
        git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
    fi
    
    # Install tmux plugins
    if [ -x "$TPM_PATH/bin/install_plugins" ]; then
        echo "Installing tmux plugins..."
        "$TPM_PATH/bin/install_plugins" 2>/dev/null || echo "  Note: Some plugins may need manual installation with prefix + I in tmux"
    fi
fi

echo "Installing FFF MCP..."
curl -fsSL https://dmtrkovalenko.dev/install-fff-mcp.sh | bash

# Setup skhd service
echo "Setting up skhd service..."
if ! skhd --status &> /dev/null; then
    echo "Installing skhd service..."
    skhd --install-service || true
fi

# Start skhd service
echo "Starting skhd service..."
skhd --start-service 2>/dev/null || skhd --restart-service 2>/dev/null || true

# Grant accessibility permissions reminder (only if not already granted)
if ! skhd --status 2>&1 | grep -q "Accessibility permissions: Granted"; then
    echo ""
    echo "====================================================="
    echo "IMPORTANT: Accessibility Permissions Required"
    echo "====================================================="
    echo "skhd requires accessibility permissions to function."
    echo ""
    echo "Please grant permissions:"
    echo "1. Open System Settings → Privacy & Security → Accessibility"
    echo "2. Add: /opt/homebrew/bin/skhd"
    echo "3. Enable the checkbox"
    echo "4. Run: skhd --restart-service"
    echo "====================================================="
fi

# Add source line to .zshrc if not present
SOURCE_LINE="source ~/.zsh/shared.zsh"
if [ -f ~/.zshrc ]; then
    if ! grep -qF "$SOURCE_LINE" ~/.zshrc; then
        echo "" >> ~/.zshrc
        echo "# Load shared dotfiles configuration" >> ~/.zshrc
        echo "$SOURCE_LINE" >> ~/.zshrc
        echo "Added source line to ~/.zshrc"
    else
        echo "Source line already present in ~/.zshrc"
    fi
else
    echo "$SOURCE_LINE" > ~/.zshrc
    echo "Created ~/.zshrc with source line"
fi

# Enable and start aerospace
echo "Enabling aerospace autostart..."
aerospace --start-at-login 2>/dev/null || true
echo "Starting aerospace..."
open -a AeroSpace 2>/dev/null || true

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Review any files adopted into your dotfiles repo with: git diff"
echo "2. Restart your terminal or run: source ~/.zshrc"

#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

echo "Setting up dotfiles from $DOTFILES_DIR..."

# Check if Homebrew is installed, install if not
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f /opt/homebrew/bin/brew ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
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

# Stow all packages - check for conflicts first
echo "Stowing all packages..."

for package in aerospace bin lazygit nvim opencode skhd tmux zsh; do
    if [ -d "$package" ]; then
        echo "Stowing $package..."
        # Check for conflicts before stowing
        CONFLICTS=$(stow -n -t ~ "$package" 2>&1 | grep "existing target is neither a link nor a directory" || true)
        if [ -n "$CONFLICTS" ]; then
            echo ""
            echo "ERROR: Conflicting files found for $package:"
            echo "$CONFLICTS" | sed 's/^/  /'
            echo ""
            echo "Please remove or backup these files manually before running install.sh again."
            exit 1
        fi
        stow -v -t ~ "$package"
    fi
done

# Install tmux plugins via TPM
if [ -f "$HOME/.config/tmux/tmux.conf" ] && [ -x "$HOME/.config/tmux/plugins/tpm/bin/install_plugins" ]; then
    echo "Installing tmux plugins..."
    "$HOME/.config/tmux/plugins/tpm/bin/install_plugins" 2>/dev/null || echo "  Note: Tmux plugins will be installed on first tmux start (press prefix + I)"
fi

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
echo "1. Restart your terminal or run: source ~/.zshrc"

#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

echo "Setting up dotfiles from $DOTFILES_DIR..."

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "Error: GNU Stow is not installed. Please install it first."
    echo "  macOS: brew install stow"
    echo "  Linux: sudo apt-get install stow (or equivalent)"
    exit 1
fi

# Stow packages
echo "Stowing packages..."
stow zsh
stow config
stow bin

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

echo ""
echo "Setup complete! Please restart your terminal or run: source ~/.zshrc"

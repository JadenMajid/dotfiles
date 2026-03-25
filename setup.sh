#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

# 1. Install Yay if not present
if ! command -v yay >/dev/null 2>&1; then
    echo "Installing yay..."
    sudo pacman -S --needed base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
fi

# 2. Add new tools to the lists if they aren't there
NEW_PKG=("eza" "zoxide" "bat" "fzf" "starship" "zsh-syntax-highlighting" "zsh-autosuggestions" "matugen")
for pkg in "${NEW_PKG[@]}"; do
    grep -qxF "$pkg" "$DOTFILES_DIR/packages.txt" || echo "$pkg" >> "$DOTFILES_DIR/packages.txt"
done

NEW_AUR=("anyrun-git" "zsh-autocomplete")
for pkg in "${NEW_AUR[@]}"; do
    grep -qxF "$pkg" "$DOTFILES_DIR/aurpackages.txt" || echo "$pkg" >> "$DOTFILES_DIR/aurpackages.txt"
done

# 3. Install Packages
echo "Installing official packages..."
sudo pacman -S --needed --noconfirm - < "$DOTFILES_DIR/packages.txt"

echo "Installing AUR packages..."
yay -S --needed --noconfirm - < "$DOTFILES_DIR/aurpackages.txt"

echo "Setup complete! Please restart your shell."

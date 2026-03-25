# Jaden's 2026 Dotfiles

A modern, high-performance, and modular Hyprland setup tailored for Arch Linux and NVIDIA hardware.

## Highlights
- Window Manager: [Hyprland](https://hyprland.org/) (Modular 2026 Syntax)
- Bar: [Waybar](https://github.com/Alexays/Waybar) (Floating Island / Pill design)
- Shell: Zsh + [Starship](https://starship.rs/) + [Zoxide](https://github.com/ajeetds/zoxide)
- Terminal: [Kitty](https://sw.kovidgoyal.net/kitty/)
- Launcher: [Anyrun](https://github.com/anyrun-org/anyrun) (Raycast-style Wayland launcher)
- Dynamic Theming: [Matugen](https://github.com/InioX/matugen) (Material You colors generated from wallpaper)
- Hardware Optimized: NVIDIA Explicit Sync & 10-bit color support for 165Hz displays.

## Structure
```text
~/dotfiles/
├── .zshrc             # Modern Zsh config (no OMZ)
├── setup.sh           # Automated installation script
├── packages.txt       # Official pacman dependencies
├── aurpackages.txt    # AUR dependencies
└── config/            # Symlinked to ~/.config/
    ├── hypr/          # Modular Hyprland & Hyprlock
    ├── waybar/        # Custom themed bar & scripts
    ├── anyrun/        # Instant Wayland launcher
    ├── matugen/       # Color generation templates
    ├── kitty/         # Terminal config
    └── starship.toml  # Cross-shell prompt
```

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/JadenMajid/dotfiles.git ~/dotfiles
   ```
2. Run the setup script:
   ```bash
   cd ~/dotfiles
   ./setup.sh
   ```
   *Note: This will install yay, system dependencies, and configured AUR packages.*

## Dynamic Colors
This setup uses Matugen. Changing your wallpaper via the scripts in ~/.config/wallpapers/ will automatically update:
- Hyprland Border Colors
- Waybar Module Styles
- Hyprlock Screen
- Kitty Terminal Colors
- Starship Prompt Colors
- Anyrun Launcher Theme

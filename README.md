# NixOS Development Workstation

A NixOS + Home Manager flake-based configuration featuring KDE Plasma 6, NVIDIA GPU support, and comprehensive development tooling with Catppuccin Mocha theming.

**System Profile:**
- Username: `wman`
- Hostname: `nixos`
- Desktop: KDE Plasma 6 (SDDM) with Wayland
- GPU: NVIDIA GTX 1080 (Pascal)
- Theme: Catppuccin Mocha with Mauve accent

## Quick Start

### Prerequisites
Enable flakes in `/etc/nixos/configuration.nix`:
```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

### Installation
```bash
# Clone configuration
sudo git clone <your-repo-url> /etc/nixos

# Generate hardware config
sudo nixos-generate-config --show-hardware-config | sudo tee /etc/nixos/nixos/hardware-configuration.nix

# Build and switch
sudo nixos-rebuild switch --flake /etc/nixos#nixos

# Reboot
sudo reboot
```

### Post-Installation
```bash
# Set up Rust toolchain
rustup default stable
rustup component add rust-src rust-analyzer
```

## Features

### Development Environment

**Languages:**
- Python 3.12 + Poetry + Pyright LSP
- Node.js 23 + npm/pnpm/yarn/Bun
- Rust (via rustup) + rust-analyzer
- Go, Zig, Elixir, Kotlin, Java 21 LTS
- PostgreSQL 16

**Editors:**
- Neovim (fully configured with LSP, Treesitter, Telescope)
- JetBrains: IntelliJ Ultimate, PyCharm Pro, WebStorm, RustRover
- Zed Editor

**Tools:**
- Git + Lazygit + GitHub CLI + Delta
- Docker + Podman with NVIDIA support
- Kubernetes: kubectl, k9s, Helm
- DBeaver, Bruno, Terraform

### System Tools

- **Terminal:** Konsole
- **Shell:** Zsh with autosuggestions, syntax highlighting, Starship prompt
- **File Managers:** Nautilus, Yazi (TUI)
- **Browsers:** Brave, Firefox
- **VPN:** ProtonVPN (auto-connects on boot)
- **Monitoring:** btop, htop, nvtop (GPU)

### Theming

Catppuccin Mocha theme applied to GTK, Qt/Kvantum, FZF, Bat, Delta, and more. JetBrainsMono Nerd Font throughout.

## KDE Keybindings

KDE keybindings are configured via System Settings → Shortcuts. Default KDE shortcuts apply; custom shortcuts can be added to `home-manager/home.nix` via `xdg.configFile."kglobalshortcutsrc"` once finalised.

## Shell Aliases

```bash
# NixOS Management
nrs    # sudo nixos-rebuild switch --flake .#nixos
nrb    # sudo nixos-rebuild boot --flake .#nixos
nu     # nix flake update
ncg    # sudo nix-collect-garbage -d

# Git
lg     # lazygit
gs     # git status
ga     # git add
gc     # git commit
gp     # git push
gpl    # git pull

# Docker
ld     # lazydocker
dc     # docker compose

# Quick Commands
ll     # eza -la --icons --git
lt     # eza --tree --icons
cat    # bat (syntax highlighting)
```

## Configuration Structure

```
.
├── flake.nix                      # Main flake configuration
├── nixos/
│   ├── configuration.nix          # System config
│   └── hardware-configuration.nix # Hardware detection
└── home-manager/
    └── home.nix                   # User config (shell, packages, theming)
```

**System Layer** (`nixos/`): Hardware, boot, services, system packages  
**User Layer** (`home-manager/`): Shell, user packages, KDE settings, theming

## Common Tasks

### Update System
```bash
nix flake update                              # Update all inputs
sudo nixos-rebuild switch --flake .#nixos     # Apply changes
```

### Maintenance
```bash
sudo nix-collect-garbage -d                   # Delete old generations
sudo nixos-rebuild switch --rollback          # Rollback to previous
```

### Add Packages
**System-wide:** Add to `environment.systemPackages` in `nixos/configuration.nix`  
**User-only:** Add to `home.packages` in `home-manager/home.nix`

### Modify KDE Settings
KDE settings live as INI files in `~/.config/`. To declaratively manage them, add entries to `xdg.configFile` in `home-manager/home.nix`:
```nix
xdg.configFile."kglobalshortcutsrc".text = ''
  [konsole]
  ...
'';
```

## Troubleshooting

### NVIDIA
```bash
nvidia-smi                           # Check driver
glxinfo | grep "OpenGL renderer"     # Verify Wayland uses NVIDIA
nvtop                                # Monitor GPU
```

**Note:** GTX 1080 requires closed-source drivers (`hardware.nvidia.open = false`)

### Services
```bash
systemctl status sddm                # Display manager
systemctl --user status pipewire     # Audio
journalctl -u sddm -f                # Live logs
```

### Firewall
Development ports open by default:
- 3000-3100: Node.js/React/Vue
- 5000-5100: Flask/Python
- 8000-8100: Django/HTTP
- 21115-21119 TCP + 21116 UDP: RustDesk (remote desktop)







# NixOS Development Workstation

A comprehensive NixOS + Home Manager flake-based configuration featuring GNOME desktop with optional Niri tiling compositor, NVIDIA GPU support, and extensive development tooling with Catppuccin Mocha theming.

**System Profile:**
- Username: `wman`
- Hostname: `nixos`
- Primary DE: GNOME (GDM) with Wayland
- Optional WM: Niri (scrollable tiling compositor)
- GPU: NVIDIA GTX 1080 (Pascal architecture)
- Theme: Catppuccin Mocha with Mauve accent

## Features

### Desktop Environments

**GNOME (Default)**
- Full desktop environment with GDM
- 4 named workspaces: Code, Web, Chat, Media
- Custom keybindings (see below)
- Catppuccin theming throughout

**Niri (Optional)**
- Scrollable tiling compositor
- Custom status bar (EWW)
- App launcher (Anyrun)
- Lock screen (Swaylock-effects)
- Notification daemon (SwayNotificationCenter)
- Select "Niri" from GDM session dropdown at login

### Development Environment

**Languages & Toolchains:**
- Python 3.12 + Poetry + LSP
- Node.js 22 + npm/pnpm/yarn/Bun + Deno
- Rust (via rustup) + rust-analyzer
- Go, Zig, Elixir, Kotlin
- Java 21 LTS + Gradle/Maven
- PostgreSQL 16

**Editors & IDEs:**
- Neovim (default editor)
- Zed Editor (modern, Rust-based)
- JetBrains: IntelliJ Ultimate, PyCharm Professional, WebStorm, RustRover

**Development Tools:**
- Git + Lazygit + Delta (enhanced diffs) + GitHub CLI
- Docker + Podman with NVIDIA container toolkit
- Kubernetes: kubectl, k9s, Helm
- Terraform, Bruno (API client)
- DBeaver (database GUI)

### System Tools

- **Terminal:** GNOME Console (kgx)
- **Shell:** Zsh with autosuggestions, syntax highlighting, completions
- **Prompt:** Starship (roundy/powerline style with full path)
- **File Managers:** Nautilus, Yazi (TUI)
- **Browser:** Brave, Firefox
- **VPN:** ProtonVPN (auto-connects on boot)
- **Monitoring:** btop, htop, nvtop (GPU), fastfetch

### Theming

- **Flavor:** Catppuccin Mocha (dark)
- **Accent:** Mauve (purple)
- **Applied to:** GTK, Qt/Kvantum, cursors, FZF, Starship, Bat, Delta, SwayNC, Swaylock
- **Fonts:** JetBrainsMono Nerd Font, Inter, comprehensive international support
- **GRUB:** WhiteSur theme (ultrawide2k resolution)

## Installation

### Prerequisites
You need an existing NixOS installation. If starting fresh, install NixOS with the GNOME ISO first.

### Step 1: Enable Flakes
Add to `/etc/nixos/configuration.nix`:
```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Then rebuild:
```bash
sudo nixos-rebuild switch
```

### Step 2: Clone This Configuration
```bash
# Create config directory
sudo mkdir -p /etc/nixos
cd /etc/nixos

# Backup existing config
sudo mv configuration.nix configuration.nix.backup

# Clone this configuration
sudo git clone <your-repo-url> .
# Or copy the files manually
```

### Step 3: Generate Hardware Configuration
```bash
sudo nixos-generate-config --show-hardware-config | sudo tee nixos/hardware-configuration.nix
```

### Step 4: Customize Variables (Optional)
Edit `flake.nix` to change username/hostname if needed:
```nix
username = "wman";
hostname = "nixos";
```

### Step 5: Build and Switch
```bash
sudo nixos-rebuild switch --flake .#nixos
```

### Step 6: Reboot
```bash
sudo reboot
```

## Post-Installation

### Set Up Rust
```bash
rustup default stable
rustup component add rust-src rust-analyzer
```

### Disable ProtonVPN Auto-Connect (Optional)
Comment out the `systemd.user.services.protonvpn-autoconnect` service in `nixos/configuration.nix` and rebuild.

### Set Up Flatpak (Optional)
For apps not in nixpkgs:
```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

## Keybindings

### GNOME Shortcuts

| Keybind | Action |
|---------|--------|
| `Super+Space` | Spotlight-like app search (Overview) |
| `Super+A` | Show All Applications |
| `Super+Return` | Terminal (GNOME Console) |
| `Super+E` | File Manager (Nautilus) |
| `Super+B` | Browser (Firefox) |
| `Super+D` | Discord (Equibop) |
| `Super+Q` | Close Window |
| `Super+F` | Toggle Maximize |
| `Super+Shift+F` | Toggle Fullscreen |
| `Super+Shift+S` | Screenshot (area) |
| `Super+1-4` | Switch to Workspace 1-4 |
| `Super+Shift+1-4` | Move Window to Workspace 1-4 |

### Niri Shortcuts

See `home-manager/niri-config.kdl` for Niri-specific keybindings.

## Shell Aliases

```bash
# NixOS Management
nrs    # sudo nixos-rebuild switch --flake .#nixos
nrb    # sudo nixos-rebuild boot --flake .#nixos
nrt    # sudo nixos-rebuild test --flake .#nixos
nu     # nix flake update
ns     # nix search nixpkgs
ncg    # sudo nix-collect-garbage -d

# Git
lg     # lazygit
gs     # git status
ga     # git add
gaa    # git add --all
gc     # git commit
gcm    # git commit -m
gp     # git push
gpl    # git pull
gd     # git diff
gco    # git checkout
gb     # git branch
glog   # git log --oneline --graph --decorate -10

# Docker
ld     # lazydocker
d      # docker
dc     # docker compose
dps    # docker ps
dpa    # docker ps -a
di     # docker images

# Quick Commands
ff     # fastfetch
ll     # eza -la --icons --git
ls     # eza --icons
la     # eza -a --icons
lt     # eza --tree --icons --level=2
cat    # bat (with syntax highlighting)
cd     # z (zoxide - smart cd)
c      # clear
e      # exit

# Quick Edit
zshrc   # nvim ~/.zshrc
nixconf # cd /etc/nixos && nvim .
```

## Starship Prompt

The prompt displays in a roundy/powerline style:
- OS icon (NixOS)
- Username
- **Full directory path** (not truncated)
- Git branch and status
- Language versions (Python, Rust, Node, Java, Go)
- Docker context
- Nix shell indicator

Colors follow Catppuccin Mocha palette.

## YAGS Startpage

A browser startpage configuration is included at `~/.config/yags/config.json` with organized links:
- **Dev:** GitHub, Claude AI, NixOS Search, Home Manager Options
- **Social:** Reddit, r/unixporn, r/NixOS, Hacker News
- **Media:** YouTube, Spotify, Twitch
- **Tools:** Proton Mail, Bitwarden, Excalidraw

Set it as your browser homepage or use a startpage extension.

## Directory Structure

```
.
├── flake.nix                      # Main flake with inputs/outputs
├── flake.lock                     # Locked dependencies
├── CLAUDE.md                      # Instructions for Claude Code AI
├── nixos/
│   ├── configuration.nix          # System config (hardware, services, packages)
│   ├── hardware-configuration.nix # Auto-generated hardware detection
│   └── niri.nix                   # Niri compositor module
└── home-manager/
    ├── home.nix                   # User config (shell, packages, theming)
    ├── niri-config.kdl            # Niri keybindings/layout (KDL format)
    ├── eww/
    │   ├── eww.yuck               # Status bar widgets (Yuck DSL)
    │   └── eww.scss               # Status bar styling
    ├── anyrun-style.css           # App launcher styling
    ├── swaync-config.json         # Notification daemon config
    └── swaync-style.css           # Notification styling
```

## Updating

```bash
cd /etc/nixos

# Update all flake inputs (nixpkgs, home-manager, etc.)
nix flake update

# Update specific input only
nix flake lock --update-input nixpkgs

# Rebuild with updates
sudo nixos-rebuild switch --flake .#nixos
```

## Maintenance

```bash
# Garbage collection (delete old generations)
sudo nix-collect-garbage -d

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Check what would change (dry run)
sudo nixos-rebuild dry-build --flake .#nixos
```

## Troubleshooting

### NVIDIA Issues

**Check driver is loaded:**
```bash
nvidia-smi
# Should show GTX 1080 and driver info
```

**Check Wayland is using NVIDIA:**
```bash
glxinfo | grep "OpenGL renderer"
# Should show: NVIDIA GeForce GTX 1080
```

**Monitor GPU usage and temperature:**
```bash
nvtop
# Or watch -n 1 nvidia-smi
```

**Test GPU in Docker:**
```bash
docker run --rm --device=nvidia.com/gpu=all ubuntu:latest nvidia-smi
```

**Important NVIDIA Notes:**
- GTX 1080 is Pascal architecture and requires closed-source drivers (`hardware.nvidia.open = false`)
- NVIDIA modules are loaded in initrd for better Wayland support
- Environment variables set for Wayland compatibility: `GBM_BACKEND`, `__GLX_VENDOR_LIBRARY_NAME`, `LIBVA_DRIVER_NAME`

### Niri Configuration

**Validate Niri config:**
```bash
niri validate ~/.config/niri/config.kdl
```

**Check if Niri session is available:**
Should appear in GDM session dropdown at login. If not, ensure `programs.niri.enable = true` in `nixos/niri.nix`.

### Equibop/Discord Not Starting

Try with GPU acceleration disabled:
```bash
equibop --disable-gpu
```

### Qt Apps Look Wrong

Apply Kvantum theme manually:
```bash
kvantummanager
# Select Catppuccin theme
```

### Firewall Blocking Development Servers

Development ports are open by default:
- 3000-3100: Node.js/React/Vue dev servers
- 5000-5100: Flask/Python servers
- 8000-8100: Django/general HTTP servers

To add more ports, edit `networking.firewall.allowedTCPPortRanges` in `nixos/configuration.nix`.

### Check Service Status

```bash
# Display manager
systemctl status gdm

# Audio server
systemctl --user status pipewire

# Live logs
journalctl -u gdm -f

# Verify Wayland session
echo $XDG_SESSION_TYPE    # Should be "wayland"
echo $WAYLAND_DISPLAY     # Should be set
```

## Customization Guide

### Adding Packages

**System-wide:** Add to `environment.systemPackages` in `nixos/configuration.nix`
```nix
environment.systemPackages = with pkgs; [
  your-package-here
];
```

**User-only:** Add to `home.packages` in `home-manager/home.nix`
```nix
home.packages = with pkgs; [
  your-package-here
];
```

### Adding Services

**System service:** Add to `services.*` in `nixos/configuration.nix`
**User service:** Add to `systemd.user.services.*` in `home-manager/home.nix`

### Changing GNOME Settings

Edit `dconf.settings` in `home-manager/home.nix`. Find setting paths with:
```bash
dconf watch /
# Then change the setting in GNOME GUI to see the path
```

### Modifying Niri Keybindings

Edit `home-manager/niri-config.kdl` (KDL syntax, not Nix). Changes require rebuild to symlink new config.

### Changing Theme Colors

Edit `catppuccin` settings in `home-manager/home.nix`:
```nix
catppuccin = {
  enable = true;
  flavor = "mocha";  # mocha, macchiato, frappe, latte
  accent = "mauve";  # blue, flamingo, green, lavender, maroon, mauve, peach, pink, red, etc.
};
```

### Updating GRUB Theme

Modify in `nixos/configuration.nix`:
```nix
boot.loader.grub2-theme = {
  theme = "whitesur";  # vimix, stylish, tela, etc.
  screen = "ultrawide2k";  # 1080p, 2k, 4k, ultrawide, etc.
};
```

## Architecture Notes

### Two-Layer Configuration Model

**System Layer** (`nixos/`): Hardware, boot, services, system packages, display managers
**User Layer** (`home-manager/`): Shell config, user packages, theming, GNOME settings, user services

Variables defined in `flake.nix` propagate through `specialArgs` to all modules.

### Shared vs. Desktop-Specific Components

**Both GNOME and Niri use:**
- PipeWire (audio)
- SwayNotificationCenter (notifications)
- NetworkManager, Catppuccin theming, system services

**Niri-specific:**
- EWW (status bar), Anyrun (launcher), Swaylock-effects (lock), Swayidle (idle management), Swaybg (wallpaper)

**GNOME-specific:**
- All settings in `dconf.settings`, GNOME Shell extensions, GDM

## License

Feel free to use, modify, and share this configuration.

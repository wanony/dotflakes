# NixOS Configuration

## Installation

### Prerequisites
You need an existing NixOS installation with GNOME. If starting fresh, install NixOS with the GNOME ISO first.

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

# Clone or copy this configuration
sudo git clone <your-repo-url> .
# Or copy the files manually
```

### Step 3: Generate Hardware Configuration
```bash
sudo nixos-generate-config --show-hardware-config | sudo tee nixos/hardware-configuration.nix
```

### Step 4: Build and Switch
```bash
sudo nixos-rebuild switch --flake .#nixos
```

### Step 6: Reboot
```bash
sudo reboot
```

## GRUB Dual Boot with Windows

This configuration uses GRUB with os-prober to automatically detect other OS installations.

## Keybindings

### GNOME Shortcuts

| Keybind | Action |
|---------|--------|
| `Super+Space` | Spotlight-like app search (Overview) |
| `Super+Return` | Open Terminal (Kitty) |
| `Super+E` | File Manager (Nautilus) |
| `Super+B` | Browser (Floorp) |
| `Super+D` | Discord (Equibop) |
| `Super+Q` | Close Window |
| `Super+F` | Toggle Maximize |
| `Super+Shift+F` | Toggle Fullscreen |
| `Super+1-4` | Switch to Workspace 1-4 |
| `Super+Shift+1-4` | Move Window to Workspace 1-4 |
| `Super+A` | Show All Applications |

## Shell Aliases

```bash
# NixOS Management
nrs    # nixos-rebuild switch
nrb    # nixos-rebuild boot
nu     # nix flake update
ns     # nix search nixpkgs
ncg    # nix-collect-garbage -d

# Git
lg     # lazygit
gs     # git status
gp     # git push
gpl    # git pull

# Docker
ld     # lazydocker
dps    # docker ps
dc     # docker compose

# Quick Commands
ff     # fastfetch
ll     # eza with icons
lt     # eza tree view
cat    # bat (with syntax highlighting)
cd     # zoxide (smart cd)
```

## Starship Prompt

The prompt shows (in roundy/powerline style):
- OS icon (NixOS)
- Username
- Full directory path 
- Git branch and status
- Language versions (Python, Rust, Node, Java, Go)
- Docker context
- Nix shell indicator

## YAGS Startpage

A startpage configuration is included at `~/.config/yags/config.json` with links to:
- Dev: GitHub, Claude AI, NixOS Search, Home Manager Options
- Social: Reddit, r/unixporn, r/NixOS, Hacker News
- Media: YouTube, Spotify, Twitch
- Tools: Proton Mail, Bitwarden, Excalidraw

Set it as your browser homepage or use a startpage extension.

## Post-Installation

### Set Up Rust
```bash
rustup default stable
rustup component add rust-src rust-analyzer
```

### Set Up Flatpak (Optional)
For apps not in nixpkgs:
```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

## Directory Structure

```
.
├── flake.nix                    # Main flake configuration
├── flake.lock                   # Locked dependencies
├── nixos/
│   ├── configuration.nix        # System configuration
│   └── hardware-configuration.nix
└── home-manager/
    └── home.nix                 # User configuration
```

## Updating

```bash
cd /etc/nixos

# Update flake inputs
nix flake update

# Rebuild
sudo nixos-rebuild switch --flake .#nixos
```

## Troubleshooting

### NVIDIA Issues

**Check driver is loaded:**
```bash
nvidia-smi
```

**Check Wayland is using NVIDIA:**
```bash
glxinfo | grep "OpenGL renderer"
# Should show: NVIDIA GeForce GTX 1080
```

**Screen flickering or tearing:**
Add to configuration.nix:
```nix
hardware.nvidia.forceFullCompositionPipeline = true;
```

**Graphical corruption after suspend:**
Enable power management:
```nix
hardware.nvidia.powerManagement.enable = true;
```

**Monitor GPU usage:**
```bash
nvtop
```

**Use GPU in Docker:**
```bash
docker run --rm -it --device=nvidia.com/gpu=all ubuntu:latest nvidia-smi
```

### Equibop Not Starting

Try with GPU acceleration disabled:
```bash
equibop --disable-gpu
```

### Qt Apps Look Wrong

The Kvantum theme might not be applied. Run:
```bash
kvantummanager
```
And select the Catppuccin theme.

## License

Feel free to use, modify, and share this configuration.


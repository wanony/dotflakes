{ config, pkgs, inputs, lib, username, hostname, ... }:

{
  system.stateVersion = "25.11";
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  time.timeZone = "Europe/London";
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };
  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
      };

      systemd-boot.enable = false;
    };

    loader.grub2-theme = {
      enable = true;
      theme = "whitesur";
      footer = true;
      screen = "ultrawide2k";
    };

    kernelParams = [ "quiet" "splash" "nvidia_drm.modeset=1" ];
    kernelPackages = pkgs.linuxPackages_latest;
    # wifi module
    kernelModules = [ "rtl8821ae" ];
    # Load NVIDIA modules early for better Wayland support
    initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  };

  nixpkgs.config.allowUnfree = true;
  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.linux-firmware ];
    graphics = {
      enable = true;
      # Enable 32-bit support for Steam, Wine, etc.
      enable32Bit = true;
    };

    nvidia = {
      # Modesetting is required for Wayland compositors (GNOME)
      modesetting.enable = true;
      # Enable if you experience graphical corruption after waking from sleep
      powerManagement.enable = false;
      # Fine-grained power management - ONLY for Turing (RTX 20xx) or newer
      # GTX 1080 is Pascal, so this must be false
      powerManagement.finegrained = false;
      # Use the proprietary NVIDIA kernel module (not the open-source one)
      # The open source module only supports Turing (RTX 20xx) and newer
      # GTX 1080 is Pascal architecture, so we MUST use closed source
      open = false;
      # Enable the nvidia-settings GUI tool
      nvidiaSettings = true;
      # Use the stable/production driver
      # GTX 1080 is well-supported by all modern drivers
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # Load NVIDIA driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";  # Adjust keyboard layout as needed
      variant = "";
    };
  };

  # GNOME Desktop Environment
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
  services.desktopManager.gnome.enable = true;
  programs.xwayland.enable = true;
  programs.dconf.enable = true;

  # Portal services for Wayland (screen sharing, file dialogs, etc.)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config = {
      common.default = "gnome";
    };
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      # Enable CDI for GPU support in containers
      daemon.settings.features.cdi = true;
    };
    # Enable Podman as an alternative
    podman = {
      enable = true;
      dockerCompat = false;
    };
  };

  # Enable NVIDIA container toolkit
  hardware.nvidia-container-toolkit.enable = true;

  # ==========================================================================
  # DEVELOPMENT TOOLS & LANGUAGES
  # ==========================================================================

  programs.git.enable = true;

  # Java/Kotlin development
  programs.java = {
    enable = true;
    package = pkgs.jdk21;  # Latest LTS
  };

  # ==========================================================================
  # NETWORKING & VPN
  # ==========================================================================

  # ProtonVPN
  services.resolved.enable = true;

  # Firewall
  networking.firewall = {
    checkReversePath = false; # for vpn
    enable = true;
    allowedTCPPorts = [ 22 80 443 8096 8920 ];  # Added 8096 (Jellyfin HTTP) and 8920 (Jellyfin HTTPS)
    # For development servers
    allowedTCPPortRanges = [
      { from = 3000; to = 3100; }  # Dev servers
      { from = 5000; to = 5100; }  # Flask/Python
      { from = 8000; to = 8100; }  # Django/other
    ];
  };

  # ==========================================================================
  # FONTS
  # ==========================================================================

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # Nerd Fonts (programming fonts with icons)
      nerd-fonts.fira-code
      # International fonts for all languages
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      liberation_ttf
      dejavu_fonts
      ubuntu-classic
      source-han-sans
      source-han-serif

      # Additional programming fonts
      jetbrains-mono
      fira-code
      cascadia-code

      # Microsoft fonts (for compatibility)
      corefonts
      vista-fonts
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" "Source Han Serif" ];
        sansSerif = [ "Noto Sans" "Source Han Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" "Fira Code" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # ==========================================================================
  # SYSTEM PACKAGES
  # ==========================================================================

  environment.systemPackages = with pkgs; [
    # --- Terminal Emulator ---
    gnome-console  # Modern GNOME terminal (replaces gnome-terminal)

    # --- Core CLI Tools ---
    coreutils
    gnumake
    cmake
    gcc
    clang
    wget
    curl
    htop
    btop
    tree
    unzip
    zip
    p7zip
    ripgrep
    fd
    fzf
    bat
    eza
    zoxide
    jq
    yq
    tldr
    ntfs3g

    # --- Development Languages ---
    # Python
    python312
    python312Packages.pip
    python312Packages.virtualenv
    python312Packages.black
    python312Packages.pytest
    python312Packages.ipython
    poetry

    # TypeScript/Node.js
    nodejs_24
    nodePackages.npm
    nodePackages.pnpm
    nodePackages.yarn
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.eslint
    nodePackages.prettier

    # Rust
    rustup
    cargo-watch
    cargo-edit

    # Zig
    zig
    # Elixir
    beamMinimal28Packages.elixir
    # Go
    go

    # Kotlin
    kotlin
    gradle
    maven

    # databases
    postgresql_16

    # --- Editors & IDEs ---
    neovim
    # Zed editor (FOSS, Rust-based, fast)
    zed-editor

    # --- JetBrains IDEs ---
    jetbrains.idea      # IntelliJ IDEA
    jetbrains.rust-rover         # Rust IDE

    # --- Version Control ---
    git
    git-lfs
    lazygit
    gh  # GitHub CLI

    # --- Containers & Cloud ---
    docker-compose
    lazydocker
    kubectl
    k9s
    helm
    terraform

    # --- API Development ---
    bruno  # FOSS API client

    # --- Browsers ---
    brave
    firefox

    # --- Communication ---
    equibop  # Enhanced Discord client

    # --- Media ---
    vlc
    mpv
    ffmpeg

    # --- Jellyfin ---
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg

    # --- VPN ---
    wireguard-tools
    protonvpn-gui
    qbittorrent

    # --- System Monitoring ---
    fastfetch
    neofetch
    duf  # Disk usage
    ncdu # NCurses disk usage
    nvtopPackages.nvidia  # NVIDIA GPU monitoring (like htop for GPU)

    # --- NVIDIA Tools ---
    mesa-demos  # Check OpenGL info
    vulkan-tools  # Check Vulkan info
    libva-utils  # Check VA-API (video acceleration)

    # --- GNOME Utilities ---
    wl-clipboard
    gnome-tweaks
    gnome-extension-manager
    dconf-editor

    # --- File Management ---
    nautilus
    yazi  # TUI file manager

    # --- Database Tools ---
    dbeaver-bin

    # --- Networking ---
    networkmanagerapplet
    nmap
    wireshark

    # --- Productivity ---
    # obsidian  # Note-taking

    # --- Misc Development ---
    direnv  # Per-directory environments
    starship
    zellij

    # --- Security ---
    gnupg
    pinentry-gnome3
    keepassxc
  ];

  # ==========================================================================
  # PROGRAMS CONFIGURATION
  # ==========================================================================

  programs = {
    # Neovim system-wide
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    zsh.enable = true;
    fish.enable = true;
    starship.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    seahorse.enable = true;
  };

  # ==========================================================================
  # SERVICES
  # ==========================================================================

  services = {
    # SSH
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    # Printing
    printing.enable = true;

    # Bluetooth
    blueman.enable = true;

    # Flatpak
    flatpak.enable = true;

    # Jellyfin Media Server
    jellyfin = {
      enable = true;
      group = "users";
    };
  };

  # ==========================================================================
  # USER CONFIGURATION
  # ==========================================================================

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "audio"
      "video"
      "input"
      "dialout"
    ];
    shell = pkgs.zsh;
  };

  # security.sudo.wheelNeedsPassword = false;

  systemd.user.services.protonvpn-autoconnect = {
    description = "Auto connect to VPN";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.protonvpn-gui}/bin/protonvpn-cli connect --fastest";
      RemainAfterExit = true;
    };
  };

  # ==========================================================================
  # ENVIRONMENT VARIABLES
  # ==========================================================================

  environment.sessionVariables = {
    # Wayland
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";

    # NVIDIA Wayland compatibility
    # These help Electron apps and other software work properly with NVIDIA on Wayland
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";

    # Editor
    EDITOR = "nvim";
    VISUAL = "nvim";

    # Rust
    RUSTUP_HOME = "$HOME/.rustup";
    CARGO_HOME = "$HOME/.cargo";

    # Go
    GOPATH = "$HOME/go";

    # XDG
    XDG_CURRENT_DESKTOP = "gnome";
  };

  environment.pathsToLink = [ "/share/zsh" ];
}

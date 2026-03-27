{ config, pkgs, inputs, lib, username, hostname, ... }:

let
  claude-code-overlay = inputs.claude-code.overlays.default;
in

{
  system.stateVersion = "25.11";

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org"
        "https://claude-code.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
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

  console.keyMap = "uk";

  # ==========================================================================
  # BOOT — Legacy GRUB on /dev/sda (no EFI)
  # ==========================================================================

  boot = {
    loader = {
      grub = {
        enable = true;
        device = "/dev/sda";
        useOSProber = true;
      };
      grub2-theme = {
        enable = true;
        theme = "whitesur";
        footer = true;
        screen = "1080p";
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "quiet" "splash" ];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ claude-code-overlay ];

  # ==========================================================================
  # HARDWARE — Intel HD Graphics 3000 (Sandy Bridge)
  # ==========================================================================

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.linux-firmware ];
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        # Sandy Bridge VA-API support (hardware video decode for Jellyfin)
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
  };

  # ==========================================================================
  # DISPLAY — XFCE + LightDM on X11
  # ==========================================================================

  services.xserver = {
    enable = true;
    videoDrivers = [ "modesetting" ];
    xkb = {
      layout = "gb";
      variant = "";
    };
  };

  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.displayManager.lightdm.enable = true;

  # Touchpad support
  services.libinput.enable = true;

  # XDG portals (file pickers, screen sharing etc.)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };

  # dconf for GTK app settings
  programs.dconf.enable = true;

  # ==========================================================================
  # AUDIO — PipeWire
  # ==========================================================================

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ==========================================================================
  # VIRTUALISATION
  # ==========================================================================

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
    podman = {
      enable = true;
      dockerCompat = false;
    };
  };

  # ==========================================================================
  # PROGRAMS
  # ==========================================================================

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
    git.enable = true;
    zsh.enable = true;
    fish.enable = true;
    starship.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  # ==========================================================================
  # FONTS
  # ==========================================================================

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      liberation_ttf
      dejavu_fonts
      ubuntu-classic
      source-han-sans
      source-han-serif
      jetbrains-mono
      fira-code
      cascadia-code
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
    # --- Terminal ---
    xfce4-terminal

    # --- Core CLI Tools ---
    coreutils
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

    # --- Editor ---
    neovim

    # --- Version Control ---
    git
    git-lfs
    lazygit
    gh

    # --- Containers ---
    docker-compose
    lazydocker

    # --- Browser ---
    firefox

    # --- Media ---
    mpv
    ffmpeg
    jellyfin-web
    jellyfin-ffmpeg
    ncmpcpp  # MPD TUI client

    # --- VPN & Networking ---
    wireguard-tools
    protonvpn-gui
    qbittorrent

    # --- System Monitoring ---
    fastfetch
    ncdu

    # --- Clipboard (X11) ---
    xclip

    # --- File Management ---
    yazi

    # --- Networking ---
    networkmanagerapplet
    nmap

    # --- Remote Access ---
    # rustdesk builds from source and OOMs on <8GB RAM machines.
    # Install via Flatpak after first boot:
    #   flatpak install flathub com.rustdesk.RustDesk

    # --- Misc Development Utilities ---
    direnv
    starship
    zellij

    # --- Security ---
    gnupg
    pinentry-curses
    keepassxc
  ];

  # ==========================================================================
  # NETWORKING & FIREWALL
  # ==========================================================================

  services.resolved.enable = true;

  networking.firewall = {
    checkReversePath = false; # required for VPN
    enable = true;
    allowedTCPPorts = [
      22    # SSH
      80    # HTTP
      443   # HTTPS
      8096  # Jellyfin HTTP
      8920  # Jellyfin HTTPS
      21115 # RustDesk
      21116 # RustDesk
      21117 # RustDesk
      21118 # RustDesk
      21119 # RustDesk
    ];
    allowedUDPPorts = [
      21116 # RustDesk relay
    ];
    allowedTCPPortRanges = [
      { from = 3000; to = 3100; }
      { from = 5000; to = 5100; }
      { from = 8000; to = 8100; }
    ];
  };

  # ==========================================================================
  # SERVICES
  # ==========================================================================

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    printing.enable = true;
    blueman.enable = true;
    flatpak.enable = true;
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

  # ==========================================================================
  # ENVIRONMENT VARIABLES
  # ==========================================================================

  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "firefox";
    XDG_CURRENT_DESKTOP = "xfce";
  };

  environment.pathsToLink = [ "/share/zsh" ];
}

{ config, pkgs, lib, ... }:

{
  # Enable Niri window manager
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # Required services for Niri
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # XDG Desktop Portal for Niri
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    # Don't override the portal config - let configuration.nix handle it
  };

  # Polkit authentication agent
  security.polkit.enable = true;

  # Required packages for Niri ecosystem
  environment.systemPackages = with pkgs; [
    # Niri itself
    niri
    
    # Wayland essentials
    wayland
    wayland-protocols
    wayland-utils
    
    # Session management
    tuigreet
    
    # Screenshot tools
    grim
    slurp
    wl-clipboard
    
    # Notification daemon
    swaynotificationcenter
    
    # Screen locker
    swaylock-effects
    
    # Wallpaper
    swaybg
    
    # App launcher
    anyrun
    
    # Status bar (Eww)
    eww
    
    # Idle management
    swayidle
    
    # Audio control
    pavucontrol
    pamixer
    
    # Network management
    networkmanagerapplet
    
    # Brightness control (for laptops)
    brightnessctl
    
    # Power management
    playerctl
  ];

  # Enable required services
  services.dbus.enable = true;
  
  # PipeWire for audio (already enabled, but ensuring)
  services.pipewire.enable = true;

  # Enable seat management
  services.logind.settings = {
    Login = {
      HandlePowerKey = "suspend";
      HandleLidSwitch = "suspend";
    };
  };

  # NVIDIA-specific configuration for Niri
  environment.sessionVariables = {
    # Required for NVIDIA on Wayland
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    
    # Niri-specific NVIDIA workaround for VRAM usage
    NIRI_NO_DIRECT_SCANOUT = "1";
  };
}

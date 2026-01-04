{ config, pkgs, lib, ... }:

{
  # Enable Niri window manager
  # This automatically registers niri as a session in GDM/SDDM
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # XDG Desktop Portal for Niri
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config = {
      niri.default = ["gnome" "gtk"];
    };
  };

  # Polkit authentication agent
  security.polkit.enable = true;

  # Required packages for Niri ecosystem
  environment.systemPackages = with pkgs; [
    # Wayland essentials
    wayland
    wayland-protocols
    wayland-utils

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

  # NVIDIA VRAM usage fix - prevents VRAM leak (can save up to 2.5GB)
  # See: https://github.com/YaLTeR/niri/wiki/Nvidia
  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text = ''
    {
      "profiles": [
        {
          "name": "niri VRAM pool limit",
          "settings": [ "GLVidHeapReuseRatio=0" ],
          "rules": [ { "pattern": { "feature": "procname", "matches": "niri" } } ]
        }
      ]
    }
  '';
}

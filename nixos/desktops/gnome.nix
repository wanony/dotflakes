{ config, pkgs, lib, ... }:

{
  # GNOME Desktop Environment
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  services.desktopManager.gnome.enable = true;
  programs.xwayland.enable = true;
  programs.dconf.enable = true;

  # Portal services for GNOME (screen sharing, file dialogs, etc.)
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

  # GNOME-specific services
  services.gnome = {
    gnome-keyring.enable = true;
    sushi.enable = true;  # File previewer
  };

  programs.seahorse.enable = true;

  # GNOME-specific packages
  environment.systemPackages = with pkgs; [
    gnome-console
    gnome-tweaks
    gnome-extension-manager
    dconf-editor
    nautilus
    wl-clipboard
  ];

  # XDG environment
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "gnome";
  };
}

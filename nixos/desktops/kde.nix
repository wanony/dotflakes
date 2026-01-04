{ config, pkgs, lib, ... }:

{
  # KDE Plasma 6 Desktop Environment
  services.xserver.enable = true;

  # SDDM Display Manager with Wayland support
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Enable KDE Plasma 6
  services.desktopManager.plasma6.enable = true;
  programs.xwayland.enable = true;
  programs.dconf.enable = true;

  # Portal services for KDE (screen sharing, file dialogs, etc.)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
    ];
    config = {
      common.default = "kde";
    };
  };

  # KDE-specific packages
  environment.systemPackages = with pkgs; [
    # SDDM theme configuration in Plasma settings
    kdePackages.sddm-kcm

    # KDE applications
    kdePackages.kate
    kdePackages.konsole
    kdePackages.dolphin
    kdePackages.ark
    kdePackages.filelight
    kdePackages.spectacle  # Screenshot tool
    kdePackages.kcalc

    # KDE system settings
    kdePackages.systemsettings
    kdePackages.plasma-browser-integration

    # Clipboard manager
    wl-clipboard
  ];

  # XDG environment
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "KDE";
  };

  # Enable KWallet for password management
  security.pam.services.sddm.enableKwallet = true;
  security.pam.services.login.enableKwallet = true;
}

# Hardware configuration for homelab laptop
# Intel Core i5-2520M (Sandy Bridge), Intel HD Graphics 3000
# 6GB RAM, 120GB SSD
# Do not modify this file directly — regenerate with:
#   sudo nixos-generate-config --show-hardware-config
# then compare and update as needed.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/93699283-9bd7-4944-9336-ea702e7dcc72";
    fsType = "ext4";
  };

  # 4GB swapfile — create before first nixos-rebuild:
  #   sudo dd if=/dev/zero of=/var/lib/swapfile bs=1M count=4096
  #   sudo chmod 600 /var/lib/swapfile
  #   sudo mkswap /var/lib/swapfile
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 4096;
  }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

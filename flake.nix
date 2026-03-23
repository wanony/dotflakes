{
  description = "wman's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Catppuccin theming
    catppuccin.url = "github:catppuccin/nix";
    grub2-themes.url = "github:vinceliuice/grub2-themes";
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs = { self, nixpkgs, home-manager, catppuccin, grub2-themes, ... }@inputs:
    let
      system = "x86_64-linux";

      mkHost = { hostname, username, systemModules, hmUser }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs username hostname; };
          modules = systemModules ++ [
            grub2-themes.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs username; };
                users.${username} = hmUser;
              };
            }
          ];
        };

    in {
      # Main desktop: KDE Plasma 6 + Wayland + NVIDIA (AMD CPU), user wman
      nixosConfigurations.nixos = mkHost {
        hostname = "nixos";
        username = "wman";
        systemModules = [
          ./nixos/hardware-configuration.nix
          ./nixos/configuration.nix
        ];
        hmUser = import ./home-manager/home.nix;
      };

      # Homelab laptop: XFCE + X11 + Intel i5-2520M, user gigi
      nixosConfigurations.homelab = mkHost {
        hostname = "homelab";
        username = "gigi";
        systemModules = [
          ./nixos/homelab/hardware-configuration.nix
          ./nixos/homelab/configuration.nix
        ];
        hmUser = import ./home-manager/homelab/home.nix;
      };
    };
}

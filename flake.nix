{
  description = "NixOS configuration for multiple machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    vscode-insiders.url = "github:iosmanthus/code-insiders-flake";
    vscode-insiders.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      zen-browser,
      home-manager,
      plasma-manager,
      nixos-hardware,
      vscode-insiders,
    }:
    let
      system = "x86_64-linux";
      
      # Helper function to create host configurations
      mkHost = { hostname, hardware-modules, profile-modules ? [] }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./modules/base.nix
            ./modules/profiles.nix
          ] ++ hardware-modules ++ profile-modules ++ [
            {
              networking.hostName = hostname;
              _module.args = { inherit inputs; };
            }
          ];
          specialArgs = { 
            inherit inputs;
            inherit hostname;
          };
        };

      # Hardware configurations
      laptopHardware = [
        ./hardware/laptop.nix
        ./modules/tlp.nix
        ./modules/update-on-shutdown.nix
        inputs.nixos-hardware.nixosModules.lenovo-yoga-7-14ILL10
      ];

      desktopHardware = [
        ./hardware/desktop.nix
        ./modules/update-on-shutdown.nix
      ];

      # Software profiles
      laptopProfile = ./profiles/laptop.nix;
      desktopProfile = ./profiles/desktop.nix;

      # Host configurations
      laptop = mkHost {
        hostname = "mario-laptop";
        hardware-modules = laptopHardware;
        profile-modules = [ laptopProfile ];
      };

      desktop = mkHost {
        hostname = "desktop";
        hardware-modules = desktopHardware;
        profile-modules = [ desktopProfile ];
      };

    in
    {
      nixosConfigurations = {
        laptop = laptop;
        desktop = desktop;
        # Host aliases
        mario-laptop = laptop;
        mario-desktop = desktop;
        # Default configuration
        nixos = laptop;
      };
    };
}

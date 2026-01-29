{ config, lib, inputs, ... }:

let
  nixosModules = with config.flake.modules.nixos; [
    # Base system
    base-boot
    base-networking
    base-nix
    base-users

    # Hardware (VM)
    hardware-proxmox-vm

    # Shell
    shell-fish

    # Development (headless)
    dev-headless
    dev-containers

    # Services
    service-ssh
    service-syncthing
    service-update-on-shutdown

    # Secrets & overlays
    secrets
    overlays
  ];

  homeModules = with config.flake.modules.homeManager; [
    # Shell & programs (headless)
    shell-fish
    programs-git
    programs-headless
  ];
in
{
  flake.nixosConfigurations.mariogk-vm = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = nixosModules ++ [
      # Host-specific configuration
      {
        networking.hostName = "mariogk-vm";
        system.stateVersion = "24.11";
      }

      # Hardware configuration
      ../../hardware-configurations/mariogk-vm.nix

      # Home Manager integration
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
          users.mariogk = { config, ... }: {
            imports = homeModules;
            home = {
              username = "mariogk";
              homeDirectory = "/home/mariogk";
              stateVersion = "24.11";
            };
            programs.home-manager.enable = true;

            # XDG directories (minimal for headless)
            xdg.enable = true;

            # CLI editor
            home.sessionVariables = {
              EDITOR = "nano";
              VISUAL = "nano";
            };
          };
        };
      }
    ];
  };
}

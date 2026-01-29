{ config, lib, inputs, ... }:

let
  nixosModules = with config.flake.modules.nixos; [
    # Base system
    base-boot
    base-networking
    base-nix
    base-users
    base-audio
    base-bluetooth

    # Hardware (VM)
    hardware-qemu-vm

    # Desktop
    desktop-plasma
    desktop-fonts

    # Shell
    shell-fish

    # Development
    dev-core
    dev-containers

    # Services
    service-ssh
    service-flatpak
    service-performance

    # Overlays (no secrets for test-vm)
    overlays
  ];

  homeModules = with config.flake.modules.homeManager; [
    # Desktop
    desktop-plasma

    # Shell & programs
    shell-fish
    programs-git
    programs-desktop
    programs-terminals
  ];
in
{
  flake.nixosConfigurations.test-vm = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = nixosModules ++ [
      # Host-specific configuration
      {
        networking.hostName = "test-vm";
        system.stateVersion = "24.11";
      }

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

            # XDG directories
            xdg = {
              enable = true;
              userDirs = {
                enable = true;
                createDirectories = true;
                desktop = "${config.home.homeDirectory}/Desktop";
                documents = "${config.home.homeDirectory}/Documents";
                download = "${config.home.homeDirectory}/Downloads";
                music = "${config.home.homeDirectory}/Music";
                pictures = "${config.home.homeDirectory}/Pictures";
                videos = "${config.home.homeDirectory}/Videos";
              };
            };

            # Session variables
            home.sessionVariables = {
              EDITOR = "code --wait";
              VISUAL = "code --wait";
            };

            # Certificate management
            home.packages = [ inputs.nixpkgs.legacyPackages.x86_64-linux.nssTools ];
          };
        };
      }
    ];
  };
}

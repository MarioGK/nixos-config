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

    # Hardware
    hardware-amd-desktop

    # Desktop
    desktop-plasma
    desktop-fonts

    # Shell
    shell-fish

    # Development
    dev-core
    dev-containers
    dev-virtualization

    # Gaming
    gaming

    # Services
    service-ssh
    service-syncthing
    service-flatpak
    service-pangolin
    service-update-on-shutdown
    service-performance

    # Secrets & overlays
    secrets
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

    # Secrets
    secrets
  ];
in
{
  flake.nixosConfigurations.mariogk-desktop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = nixosModules ++ [
      # Host-specific configuration
      {
        networking.hostName = "mariogk-desktop";
        system.stateVersion = "24.11";
      }

      # Hardware configuration
      ../../hardware-configurations/mariogk-desktop.nix

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

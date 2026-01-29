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

    # Hardware (VM with disko)
    hardware-qemu-vm
    hardware-disko-vm

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
    service-update-on-shutdown
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

        # Set password for test-vm (not using secrets)
        users.users.mariogk.hashedPassword = "$6$xfKQIbtkx/vzmx/K$lNQZ7rAjLjF8IfOFrxK4wAWyxVxhXDDB1STo1cAhI7Nef93HwCCft/HKGMaiNkfMr/FazicggrAKSRxsxpq1H/";

        # VM-specific overrides
        # Disable iwd and WiFi entirely (not needed in VM)
        networking.wireless.iwd.enable = lib.mkForce false;
        networking.wireless.enable = lib.mkForce false;
      }

      # Home Manager integration
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
          users.mariogk = { config, pkgs, ... }: {
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
            home.packages = [ pkgs.nssTools ];

            # VM-specific: Disable rbw (requires secrets/bitwarden server)
            programs.rbw.enable = lib.mkForce false;
            # Remove the rbw-related systemd units
            systemd.user.services.rbw-agent = lib.mkForce {};
            systemd.user.services.rbw-sync = lib.mkForce {};
            systemd.user.timers.rbw-sync = lib.mkForce {};
          };
        };
      }
    ];
  };
}

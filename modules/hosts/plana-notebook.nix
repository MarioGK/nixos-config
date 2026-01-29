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
    hardware-amd-laptop

    # Desktop
    desktop-plasma
    desktop-fonts

    # Shell
    shell-fish

    # Development
    dev-core
    dev-containers
    dev-virtualization

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
  flake.nixosConfigurations.plana-notebook = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = nixosModules ++ [
      # Host-specific configuration
      ({ config, lib, pkgs, ... }: {
        networking.hostName = "plana-notebook";
        system.stateVersion = "24.11";

        # ===== WORK LAPTOP SPECIFIC =====

        # Microsoft Intune for enterprise device management
        services.intune.enable = true;

        # Intune requires gnome-keyring for credential storage
        services.gnome.gnome-keyring.enable = true;

        # Ensure SDDM unlocks gnome-keyring on login (for KDE Plasma)
        security.pam.services.sddm.enableGnomeKeyring = true;

        # NetworkManager OpenVPN plugin for GUI integration
        networking.networkmanager.plugins = with pkgs; [ networkmanager-openvpn ];

        # Microsoft Edge (required for Intune conditional access)
        # OpenVPN for VPN connectivity
        # Slack for team communication
        environment.systemPackages = with pkgs; [
          microsoft-edge
          openvpn
          slack
          azure-cli
        ];
      })

      # Hardware configuration
      ../../hardware-configurations/plana-notebook.nix

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

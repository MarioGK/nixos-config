{ inputs }:

let
  inherit (inputs.nixpkgs) lib;
in
{
  mkHost = { hostname, system, hardwareModules ? [], profiles ? [], extraModules ? [] }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs hostname;
      };

      modules = [
        # Host-specific configuration
        ../hosts/${hostname}

        # Core modules
        ../modules/core/boot.nix
        ../modules/core/networking.nix
        ../modules/core/nix.nix
        ../modules/core/users.nix

        # Common hardware modules
        ../modules/hardware/audio.nix
        ../modules/hardware/bluetooth.nix

        # Desktop modules
        ../modules/desktop/plasma.nix
        ../modules/desktop/fonts.nix

        # Services
        ../modules/services/pangolin.nix
        ../modules/services/syncthing.nix
        ../modules/services/flatpak.nix
        ../modules/services/update-on-shutdown.nix
        ../modules/services/ssh.nix

        # Programs
        ../modules/programs/containers.nix
        ../modules/programs/development.nix

        # Home Manager
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users.mariogk = import ../home;
          };
        }

        # sops-nix
        inputs.sops-nix.nixosModules.sops

        # Overlays
        {
          nixpkgs.overlays = import ../overlays { inherit inputs; };
        }
      ] ++ hardwareModules ++ profiles ++ extraModules;
    };

  # Headless variant for VMs and servers (no desktop environment)
  mkHostHeadless = { hostname, system, hardwareModules ? [], profiles ? [], extraModules ? [] }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs hostname;
      };

      modules = [
        # Host-specific configuration
        ../hosts/${hostname}

        # Core modules
        ../modules/core/boot.nix
        ../modules/core/networking.nix
        ../modules/core/nix.nix
        ../modules/core/users.nix

        # Services (server-appropriate only)
        ../modules/services/syncthing.nix
        ../modules/services/update-on-shutdown.nix
        ../modules/services/ssh.nix

        # Programs
        ../modules/programs/containers.nix
        ../modules/programs/development-headless.nix

        # Home Manager (headless variant)
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users.mariogk = import ../home/headless.nix;
          };
        }

        # sops-nix
        inputs.sops-nix.nixosModules.sops

        # Overlays
        {
          nixpkgs.overlays = import ../overlays { inherit inputs; };
        }
      ] ++ hardwareModules ++ profiles ++ extraModules;
    };
}

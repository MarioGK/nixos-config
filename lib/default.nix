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
        ../modules/services/performance.nix

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

  # ISO builder for live environment
  mkISO = { system ? "x86_64-linux", extraModules ? [] }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs;
        hostname = "nixos-live";
      };

      modules = [
        # Base ISO module with Plasma 6
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma6-new-kernel.nix"

        # Core modules (no boot.nix - ISO handles bootloader)
        ../modules/core/networking.nix
        ../modules/core/nix.nix

        # Desktop modules
        ../modules/desktop/plasma.nix
        ../modules/desktop/fonts.nix

        # Hardware (generic)
        ../modules/hardware/audio.nix
        ../modules/hardware/bluetooth.nix

        # Programs
        ../modules/programs/containers.nix
        ../modules/programs/development.nix

        # Services (subset appropriate for live)
        ../modules/services/flatpak.nix
        ../modules/services/ssh.nix

        # Home Manager for nixos user
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users.nixos = import ../home/iso.nix;
          };
        }

        # sops-nix (system level)
        inputs.sops-nix.nixosModules.sops

        # Overlays
        {
          nixpkgs.overlays = import ../overlays { inherit inputs; };
        }

        # ISO-specific configuration
        ../iso/configuration.nix
      ] ++ extraModules;
    };
}

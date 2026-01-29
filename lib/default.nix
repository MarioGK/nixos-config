{ inputs }:

let
  inherit (inputs.nixpkgs) lib;
in
{
  mkHost = { hostname, system, extraModules ? [ ] }:
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

        # Hardware modules
        ../modules/hardware/intel-lunar-lake.nix
        ../modules/hardware/audio.nix
        ../modules/hardware/bluetooth.nix

        # Desktop modules
        ../modules/desktop/plasma.nix
        ../modules/desktop/fonts.nix

        # Services
        ../modules/services/tailscale.nix
        ../modules/services/syncthing.nix
        ../modules/services/flatpak.nix
        ../modules/services/update-on-shutdown.nix

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
      ] ++ extraModules;
    };
}

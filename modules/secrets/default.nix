{ config, lib, inputs, ... }:

{
  # NixOS module for sops-nix integration
  flake.modules.nixos.secrets = { config, lib, pkgs, ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    # sops-nix base configuration
    # Individual hosts can override with specific secrets
  };

  # Home Manager module for sops-nix integration
  flake.modules.homeManager.secrets = { config, lib, pkgs, ... }: {
    imports = [ inputs.sops-nix.homeManagerModules.sops ];

    # sops-nix secrets configuration
    sops = {
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      defaultSopsFile = ../../secrets/secrets.yaml;

      secrets = {
        "claude-credentials" = {
          path = "${config.home.homeDirectory}/.claude/.credentials.json";
        };
      };
    };
  };
}

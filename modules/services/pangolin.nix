{ config, lib, ... }:

{
  flake.modules.nixos.service-pangolin = { config, lib, pkgs, ... }: {
    # Newt - Pangolin tunnel client
    # https://docs.pangolin.net/
    services.newt = {
      enable = true;

      # Environment file is managed by sops-nix
      # The file should contain: NEWT_ENDPOINT, NEWT_ID, NEWT_SECRET
      environmentFile = config.sops.secrets."pangolin/env".path;
    };

    # Declare sops secret for pangolin environment
    sops.secrets."pangolin/env" = {
      sopsFile = ../../secrets/secrets.yaml;
      restartUnits = [ "newt.service" ];
    };

    # Newt CLI tool
    environment.systemPackages = with pkgs; [
      newt
    ];
  };
}

{ config, lib, inputs, ... }:

let
  getSystem = prev: prev.stdenv.hostPlatform.system;
in
{
  # Expose overlays to the flake
  flake.overlays.default = final: prev: {
    # Zen Browser from flake
    zen-browser = inputs.zen-browser.packages.${getSystem prev}.default or inputs.zen-browser.packages.${getSystem prev}.zen-browser or null;

    # Helium Browser from flake
    helium-browser = inputs.helium-browser.packages.${getSystem prev}.default or null;

    # OpenCode from flake
    opencode = inputs.opencode.packages.${getSystem prev}.default or null;
  };

  # NixOS module to apply overlays
  flake.modules.nixos.overlays = { config, lib, pkgs, ... }: {
    nixpkgs.overlays = [ inputs.self.overlays.default ];
  };
}

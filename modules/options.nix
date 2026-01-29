{ lib, ... }:

# This module declares the flake.modules option for the dendritic pattern.
# It allows modules to be defined under flake.modules.nixos.* and flake.modules.homeManager.*
# and then referenced in host definitions.
{
  options.flake.modules = {
    nixos = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = { };
      description = "NixOS modules to be composed in host definitions";
    };
    homeManager = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = { };
      description = "Home Manager modules to be composed in host definitions";
    };
  };

  # Define the systems this flake supports (required by flake-parts)
  config.systems = [ "x86_64-linux" "aarch64-linux" ];
}

{ config, pkgs, ... }:

{
  imports = [
    ../../profiles/desktop.nix
  ];

  # This file now only contains host-specific overrides
  # Most configuration is handled by the profile system
}

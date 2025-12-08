{ config, pkgs, ... }:

{
  imports = [
    ../../profiles/laptop.nix
  ];

  # This file now only contains host-specific overrides
  # Most configuration is handled by the profile system
}

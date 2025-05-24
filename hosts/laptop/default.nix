{ config, pkgs, ... }:
{
  imports = [
    ../../modules/base.nix
    ../../hardware/laptop.nix
  ];

  networking.hostName = "mario-laptop";
}

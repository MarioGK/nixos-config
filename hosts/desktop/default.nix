{ config, pkgs, ... }:
{
  imports = [
    ../../modules/base.nix
    ../../hardware/desktop.nix
  ];

  networking.hostName = "desktop";
}

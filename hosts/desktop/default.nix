{ config, pkgs, ... }:
{
  imports = [
    ../../modules/base.nix
    ../../hardware/desktop.nix
    ../../modules/update-on-shutdown.nix
  ];

  networking.hostName = "desktop";
}

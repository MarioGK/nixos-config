{ config, pkgs, ... }:
{
  imports = [
    ../../modules/base.nix
    ../../hardware/desktop.nix
    ../../modules/update-on-shutdown.nix
  ];

  networking.hostName = "desktop";

  # AMD specific tools for the desktop
  environment.systemPackages = with pkgs; [
    amdvlk
    radeontop
    lact
  ];
}

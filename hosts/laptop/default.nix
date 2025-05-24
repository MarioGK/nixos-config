{ config, pkgs, ... }:
{
  imports = [
    ../../modules/base.nix
    ../../hardware/laptop.nix
    ../../modules/tlp.nix
    ../../modules/update-on-shutdown.nix
  ];

  networking.hostName = "mario-laptop";

  powerManagement.enable = true;

  # Force display settings for the laptop
  environment.sessionVariables = {
    #QT_SCALE_FACTOR = "1.6";
    #GDK_SCALE = "1.6";
  };


  environment.etc."xdg/kwinrc".text = ''
    [Compositing]
    EnableHDR=true
    MaxFPS=120
  '';
}

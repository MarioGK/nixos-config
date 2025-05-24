{ config, pkgs, ... }:
{
  imports = [
    ../../modules/base.nix
    ../../hardware/laptop.nix
  ];

  networking.hostName = "mario-laptop";

  # Force display settings for the laptop
  environment.sessionVariables = {
    QT_SCALE_FACTOR = "1.6";
    GDK_SCALE = "1.6";
  };


  environment.etc."xdg/kwinrc".text = ''
    [Compositing]
    EnableHDR=true
    MaxFPS=120
  '';
}

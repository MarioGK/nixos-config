{ config, pkgs, ... }:
{
  services.tlp.enable = true;
  # Disable power-profiles-daemon as it conflicts with TLP
  services.power-profiles-daemon.enable = false;
  environment.systemPackages = with pkgs; [ tlp tlpui ];
  config.services.tlp.settings = builtins.readFile ../files/tlp.conf;
}

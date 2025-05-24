{ config, pkgs, ... }:
{
  services.tlp.enable = true;
  environment.systemPackages = with pkgs; [ tlp tlpui ];
  services.tlp.extraConfig = builtins.readFile ../files/tlp.conf;
}

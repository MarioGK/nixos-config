{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  home.username = "mariogk";
  home.homeDirectory = "/home/mariogk";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.packages = [
  ];

  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
    };
  };
}

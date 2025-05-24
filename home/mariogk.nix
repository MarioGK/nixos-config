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

  programs.home-manager.enable = true;

  programs.plasma = {
    workspace = {
      enable = true;
      lookAndFeel = "org.kde.breezedark.desktop";
    };
  };
}

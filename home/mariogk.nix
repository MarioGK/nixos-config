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
  # Set the version of Home Manager used for this user's configuration.
  # This value should not be changed once initially set.
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
    };
  };
}

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./shell.nix
    ./terminals.nix
    ./git.nix
    ./programs.nix
    ./plasma.nix

    # plasma-manager for declarative KDE config
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  home = {
    username = "mariogk";
    homeDirectory = "/home/mariogk";

    # This value determines the Home Manager release that your configuration is
    # compatible with. Don't change this unless you understand what it does.
    stateVersion = "24.11";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # XDG directories
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";
    };
  };

  # Session variables
  home.sessionVariables = {
    EDITOR = "code --wait";
    VISUAL = "code --wait";
  };
}

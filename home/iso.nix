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
    username = "nixos";
    homeDirectory = "/home/nixos";
    stateVersion = "24.11";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # XDG directories for nixos user
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

  # Disable sops - no age key yet on live ISO
  # User will set up after rbw register

  # Disable rbw auto-unlock service (user registers manually)
  systemd.user.services.rbw-agent.enable = lib.mkForce false;
  systemd.user.services.rbw-sync.enable = lib.mkForce false;
  systemd.user.timers.rbw-sync.enable = lib.mkForce false;

  # Session variables
  home.sessionVariables = {
    EDITOR = "code --wait";
    VISUAL = "code --wait";
  };
}

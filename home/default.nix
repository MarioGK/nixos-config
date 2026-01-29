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

    # sops-nix for secrets management
    inputs.sops-nix.homeManagerModules.sops
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

  # sops-nix secrets configuration
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets/secrets.yaml;

    secrets = {
      "claude-credentials" = {
        path = "${config.home.homeDirectory}/.claude/.credentials.json";
      };
    };
  };

  # Session variables
  home.sessionVariables = {
    EDITOR = "code --wait";
    VISUAL = "code --wait";
  };

  # User packages
  home.packages = with pkgs; [
    # Certificate management (for dotnet dev-certs trust)
    nssTools  # Provides certutil for browser certificate trust
  ];
}

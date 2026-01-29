{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./shell.nix               # Fish shell config
    ./git.nix                 # Git config
    ./programs-headless.nix   # CLI-only programs
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

  # XDG directories (minimal for headless)
  xdg.enable = true;

  # CLI editor instead of VSCode
  home.sessionVariables = {
    EDITOR = "nano";
    VISUAL = "nano";
  };
}

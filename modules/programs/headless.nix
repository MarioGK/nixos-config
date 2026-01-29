{ config, lib, ... }:

{
  flake.modules.homeManager.programs-headless = { config, lib, pkgs, ... }: {
    home.packages = with pkgs; [
      # System monitoring
      htop
      btop

      # File management
      p7zip
      unzip
      unrar

      # Networking
      wget
      aria2

      # Utilities
      fastfetch
      tree
      tldr
    ];

    # Btop configuration
    programs.btop = {
      enable = true;
      settings = {
        color_theme = "dracula";
        theme_background = false;
        vim_keys = true;
      };
    };
  };
}

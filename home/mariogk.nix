{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
    ./vscode-insiders.nix # Import the new file
  ];

  home.username = "mariogk";
  home.homeDirectory = "/home/mariogk";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # The nixpkgs.overlays definition for vscode-insiders is now in vscode-insiders.nix
  # and will be merged via the import.

  home.packages = [
    config.nixpkgs.pkgs.vscode-insiders # This will pick up the overlaid package via the imported module
  ];

  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
    };
  };
}

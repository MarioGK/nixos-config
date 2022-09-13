#
#  Hyprland NixOS & Home manager configuration
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ ./laptop
#   │       └─ home.nix
#   └─ ./modules
#       └─ ./desktop
#           └─ ./hyprland
#               └─ home.nix *
#

{ config, lib, pkgs, ... }:

{
  home.file = {
    ".config/hypr/hyprland.conf".text = readFile hyprland.conf;
  };
}

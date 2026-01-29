{ config, lib, pkgs, hostname, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # System state version - DO NOT CHANGE after initial install
  system.stateVersion = "24.11";

  # Link /etc/nixos to this repository
  # Run: sudo ln -sf /home/mariogk/Projects/nixos-config /etc/nixos
}

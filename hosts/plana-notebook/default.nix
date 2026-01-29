{ config, lib, pkgs, hostname, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # System state version - DO NOT CHANGE after initial install
  system.stateVersion = "24.11";

  # ===== WORK LAPTOP SPECIFIC =====

  # Microsoft Intune for enterprise device management
  services.intune.enable = true;

  # Intune requires gnome-keyring for credential storage
  services.gnome.gnome-keyring.enable = true;

  # Ensure SDDM unlocks gnome-keyring on login (for KDE Plasma)
  security.pam.services.sddm.enableGnomeKeyring = true;

  # NetworkManager OpenVPN plugin for GUI integration
  networking.networkmanager.plugins = with pkgs; [ networkmanager-openvpn ];

  # Microsoft Edge (required for Intune conditional access)
  # OpenVPN for VPN connectivity
  # Slack for team communication
  environment.systemPackages = with pkgs; [
    microsoft-edge
    openvpn
    slack
    azure-cli
  ];

  # Link /etc/nixos to this repository
  # Run: sudo ln -sf /home/mariogk/Projects/nixos-config /etc/nixos
}

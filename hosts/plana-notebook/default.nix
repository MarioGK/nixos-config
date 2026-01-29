{ config, lib, pkgs, hostname, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # System state version - DO NOT CHANGE after initial install
  system.stateVersion = "24.11";

  # Locale settings
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
    };
  };

  # Timezone
  time.timeZone = "America/Sao_Paulo";

  # Console settings
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ===== WORK LAPTOP SPECIFIC =====

  # Microsoft Intune for enterprise device management
  services.intune.enable = true;

  # Intune requires gnome-keyring for credential storage
  services.gnome.gnome-keyring.enable = true;

  # Ensure SDDM unlocks gnome-keyring on login (for KDE Plasma)
  security.pam.services.sddm.enableGnomeKeyring = true;

  # Microsoft Edge (required for Intune conditional access)
  environment.systemPackages = with pkgs; [
    microsoft-edge
  ];

  # Link /etc/nixos to this repository
  # Run: sudo ln -sf /home/mariogk/Projects/nixos-config /etc/nixos
}

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

  # Link /etc/nixos to this repository
  # Run: sudo ln -sf /home/mariogk/Projects/nixos-config /etc/nixos
}

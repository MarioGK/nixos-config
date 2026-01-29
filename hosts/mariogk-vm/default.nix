{ config, lib, pkgs, hostname, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # System state version - DO NOT CHANGE after initial install
  system.stateVersion = "24.11";

  # Enable SSH for remote access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Open SSH port
  networking.firewall.allowedTCPPorts = [ 22 ];
}

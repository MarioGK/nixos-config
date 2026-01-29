{ config, lib, pkgs, hostname, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # System state version
  system.stateVersion = "24.11";

  # ===== VM-SPECIFIC OVERRIDES =====

  # Disable services that require secrets or external config
  services.newt.enable = lib.mkForce false;
  services.syncthing.enable = lib.mkForce false;

  # Enable SPICE/QXL for better VM graphics
  services.spice-vdagentd.enable = true;

  # Auto-login for easier testing
  services.displayManager.autoLogin = {
    enable = true;
    user = "mariogk";
  };
}

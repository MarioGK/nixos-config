{ config, lib, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";  # Enable subnet routing as client
  };

  # Open firewall for Tailscale
  networking.firewall = {
    checkReversePath = "loose";  # Required for Tailscale
    allowedUDPPorts = [ 41641 ];  # Tailscale port
  };

  # Tailscale CLI
  environment.systemPackages = with pkgs; [
    tailscale
  ];
}

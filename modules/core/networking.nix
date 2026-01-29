{ config, lib, pkgs, hostname, ... }:

{
  networking = {
    hostName = hostname;

    # Use NetworkManager for WiFi and connections
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    # Use iwd for WiFi 7 support (Intel BE201)
    wireless.iwd = {
      enable = true;
      settings = {
        General = {
          EnableNetworkConfiguration = false;  # Let NetworkManager handle this
        };
        Settings = {
          AutoConnect = true;
        };
      };
    };

    # Firewall configuration
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22000  # Syncthing transfer
      ];
      allowedUDPPorts = [
        22000  # Syncthing transfer
        21027  # Syncthing discovery
      ];
      # Tailscale interface is trusted
      trustedInterfaces = [ "tailscale0" ];
    };

    # Disable wpa_supplicant (using iwd instead)
    wireless.enable = false;
  };

  # Enable systemd-resolved for DNS
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    fallbackDns = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };
}

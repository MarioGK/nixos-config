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
    };

    # Disable wpa_supplicant (using iwd instead)
    wireless.enable = false;
  };

  # Enable systemd-resolved for DNS
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNSSEC = "allow-downgrade";
        FallbackDNS = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };
    };
  };

  # Avahi for mDNS/DNS-SD (local network discovery)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}

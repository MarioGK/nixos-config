{ config, lib, ... }:

{
  flake.modules.nixos.service-ssh = { config, lib, pkgs, ... }: {
    services.openssh = {
      enable = true;

      settings = {
        # Security hardening
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        KbdInteractiveAuthentication = false;

        # Only allow specific users
        AllowUsers = [ "mariogk" ];

        # Modern crypto
        KexAlgorithms = [
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
        ];
        Ciphers = [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
        ];
        Macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
        ];
      };

      # Host keys - Ed25519 only
      hostKeys = [
        { path = "/etc/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
      ];
    };

    # Firewall rule
    networking.firewall.allowedTCPPorts = [ 22 ];
  };
}

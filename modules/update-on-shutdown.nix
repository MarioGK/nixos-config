{ config, pkgs, ... }:
{
  systemd.services.update-nixos-before-shutdown = {
    description = "Update NixOS configuration before shutdown";
    wantedBy = [ "halt.target" "reboot.target" ];
    before = [ "shutdown.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash /etc/nixos/files/update-before-shutdown.sh";
    };
  };
}

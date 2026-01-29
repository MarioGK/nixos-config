{ config, lib, ... }:

{
  flake.modules.nixos.service-update-on-shutdown = { config, lib, pkgs, ... }: {
    # Update flake and rebuild on shutdown/reboot
    # This ensures the system is always up-to-date for the next boot
    systemd.services.update-on-shutdown = {
      description = "Update NixOS flake and rebuild on shutdown";
      wantedBy = [ "halt.target" "reboot.target" ];
      before = [ "halt.target" "reboot.target" "shutdown.target" ];
      requiredBy = [ "halt.target" "reboot.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStartSec = "10min";  # Allow time for updates
      };

      # Only run on shutdown, not on start
      script = ''
        # Check if this is shutdown (not boot)
        if [ ! -f /run/update-on-shutdown-ran ]; then
          touch /run/update-on-shutdown-ran
          exit 0
        fi

        echo "Updating NixOS configuration..."

        # Navigate to config directory
        cd /etc/nixos || exit 1

        # Update flake inputs
        ${pkgs.nix}/bin/nix flake update 2>&1 || true

        # Rebuild for next boot (don't switch, just prepare)
        ${pkgs.nixos-rebuild}/bin/nixos-rebuild boot --flake . 2>&1 || true

        echo "Update complete. Changes will apply on next boot."
      '';
    };

    # Create marker on boot
    systemd.services.update-on-shutdown-marker = {
      description = "Create marker for update-on-shutdown";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.coreutils}/bin/touch /run/update-on-shutdown-ran";
      };
    };
  };
}

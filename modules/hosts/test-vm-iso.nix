# Auto-install ISO for test-vm
# Boots, partitions disk with disko, installs NixOS, and powers off
{ config, lib, inputs, ... }:

let
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

  # Get the test-vm system configuration
  testVmConfig = config.flake.nixosConfigurations.test-vm;

  # Pre-build the system toplevel
  systemToplevel = testVmConfig.config.system.build.toplevel;

  # Bake the repository into the ISO for future rebuilds
  nixosConfigRepo = pkgs.stdenvNoCC.mkDerivation {
    name = "nixos-config-repo";
    src = ../..;
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out
      cp -r $src/* $out/
      # Remove any git-ignored or temporary files
      rm -rf $out/.git $out/result 2>/dev/null || true
    '';
  };
in
{
  flake.nixosConfigurations.test-vm-iso = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      # Base installation CD (UEFI compatible)
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

      {
        # ISO image settings
        image.baseName = lib.mkForce "nixos-test-vm-installer";

        # Include necessary tools
        environment.systemPackages = with pkgs; [
          git
          vim
          parted
          e2fsprogs
          dosfstools
        ];

        # Bake the config repo into the ISO for future rebuilds
        environment.etc."nixos-config".source = nixosConfigRepo;

        # Auto-install systemd service
        systemd.services.auto-install = {
          description = "Automatic NixOS installation for test-vm";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" "local-fs.target" ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            StandardOutput = "journal+console";
            StandardError = "journal+console";
            TimeoutStartSec = "30min";
          };

          path = with pkgs; [
            coreutils
            util-linux
            parted
            e2fsprogs
            dosfstools
            nix
            nixos-install-tools
          ];

          script = ''
            set -euo pipefail

            echo "=== NixOS Auto-Install for test-vm ==="
            echo "Waiting for /dev/vda to be available..."

            # Wait for disk to be available (max 60 seconds)
            for i in $(seq 1 60); do
              if [ -b /dev/vda ]; then
                echo "Disk /dev/vda found!"
                break
              fi
              sleep 1
            done

            if [ ! -b /dev/vda ]; then
              echo "ERROR: /dev/vda not found after 60 seconds"
              exit 1
            fi

            echo "Step 1: Partitioning disk..."
            # Create GPT partition table
            parted -s /dev/vda mklabel gpt

            # Create ESP partition (512MB)
            parted -s /dev/vda mkpart ESP fat32 1MiB 513MiB
            parted -s /dev/vda set 1 esp on

            # Create root partition (rest of disk)
            parted -s /dev/vda mkpart root ext4 513MiB 100%

            # Wait for partitions to appear
            sleep 2
            partprobe /dev/vda || true
            sleep 1

            echo "Step 2: Formatting partitions..."
            # Format ESP
            mkfs.vfat -F 32 -n ESP /dev/vda1

            # Format root
            mkfs.ext4 -L nixos /dev/vda2

            echo "Step 3: Mounting filesystems..."
            mount /dev/vda2 /mnt
            mkdir -p /mnt/boot
            mount /dev/vda1 /mnt/boot

            echo "Step 4: Installing NixOS from pre-built system..."
            nixos-install --system ${systemToplevel} --no-root-passwd

            echo "Step 5: Copying config to installed system..."
            mkdir -p /mnt/etc/nixos-config
            cp -r /etc/nixos-config/* /mnt/etc/nixos-config/

            # Ensure proper ownership
            chown -R root:root /mnt/etc/nixos-config

            echo "=== Installation complete! ==="
            echo "Powering off in 5 seconds..."
            sleep 5
            poweroff
          '';
        };

        # Console settings for visibility
        boot.kernelParams = [ "console=tty0" "console=ttyS0,115200" ];

        # Enable SSH for debugging if needed
        services.openssh.enable = true;
        services.openssh.settings.PermitRootLogin = "yes";
        users.users.root.initialHashedPassword = "";

        system.stateVersion = "24.11";
      }
    ];
  };
}

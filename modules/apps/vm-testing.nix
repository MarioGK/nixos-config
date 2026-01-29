# Flake apps for VM testing
{ config, lib, inputs, ... }:

{
  perSystem = { pkgs, system, ... }: {
    apps = {
      # Build the test-vm ISO
      build-test-iso = {
        type = "app";
        meta.description = "Build the test-vm auto-install ISO";
        program = toString (pkgs.writeShellScript "build-test-iso" ''
          set -euo pipefail

          echo "Building test-vm ISO..."
          echo "This may take a while on first build."
          echo ""

          # Get the flake directory (where this script is run from)
          FLAKE_DIR="$(pwd)"

          # Build the ISO
          nix build "$FLAKE_DIR#nixosConfigurations.test-vm-iso.config.system.build.isoImage" \
            --out-link result/test-vm-iso

          ISO_PATH=$(find result/test-vm-iso -name "*.iso" -type f | head -1)

          if [ -n "$ISO_PATH" ]; then
            echo ""
            echo "=== Build successful! ==="
            echo "ISO location: $ISO_PATH"
            echo ""
            echo "Next steps:"
            echo "  1. Run: nix run .#create-test-vm"
            echo "  2. Start VM: virsh start test-vm"
            echo "  3. Watch install: virt-viewer test-vm"
          else
            echo "ERROR: ISO not found in result directory"
            exit 1
          fi
        '');
      };

      # Create and configure the test VM via virt-install
      create-test-vm = {
        type = "app";
        meta.description = "Create and configure test-vm via virt-install";
        program = toString (pkgs.writeShellScript "create-test-vm" ''
          set -euo pipefail

          VM_NAME="test-vm"
          VCPUS="4"
          RAM="4096"
          DISK_SIZE="40"
          OVMF_CODE="/run/libvirt/nix-ovmf/OVMF_CODE.fd"
          OVMF_VARS="/run/libvirt/nix-ovmf/OVMF_VARS.fd"

          # Find the ISO
          FLAKE_DIR="$(pwd)"
          ISO_PATH=$(find "$FLAKE_DIR/result/test-vm-iso" -name "*.iso" -type f 2>/dev/null | head -1)

          if [ -z "$ISO_PATH" ]; then
            echo "ERROR: ISO not found. Run 'nix run .#build-test-iso' first."
            exit 1
          fi

          echo "Using ISO: $ISO_PATH"

          # Check if VM already exists
          if ${pkgs.libvirt}/bin/virsh dominfo "$VM_NAME" &>/dev/null; then
            if [ "''${FORCE_RECREATE:-}" = "1" ]; then
              echo "Removing existing VM '$VM_NAME'..."
              ${pkgs.libvirt}/bin/virsh destroy "$VM_NAME" 2>/dev/null || true
              ${pkgs.libvirt}/bin/virsh undefine "$VM_NAME" --nvram --remove-all-storage 2>/dev/null || true
            else
              echo "VM '$VM_NAME' already exists."
              echo "Use FORCE_RECREATE=1 to delete and recreate it."
              exit 1
            fi
          fi

          # Check for OVMF firmware
          if [ ! -f "$OVMF_CODE" ]; then
            echo "ERROR: OVMF firmware not found at $OVMF_CODE"
            echo "Make sure libvirtd is running and has OVMF configured."
            exit 1
          fi

          echo "Creating VM '$VM_NAME'..."
          echo "  vCPUs: $VCPUS"
          echo "  RAM: $RAM MB"
          echo "  Disk: $DISK_SIZE GB"
          echo ""

          # Create the VM
          ${pkgs.virt-manager}/bin/virt-install \
            --name "$VM_NAME" \
            --memory "$RAM" \
            --vcpus "$VCPUS" \
            --cpu host-passthrough \
            --machine q35 \
            --boot uefi,loader="$OVMF_CODE",loader.readonly=yes,loader.type=pflash,nvram.template="$OVMF_VARS" \
            --disk size="$DISK_SIZE",bus=virtio,format=qcow2 \
            --cdrom "$ISO_PATH" \
            --network network=default,model=virtio \
            --graphics spice \
            --video qxl \
            --channel spicevmc \
            --osinfo nixos-unstable \
            --noautoconsole \
            --noreboot

          echo ""
          echo "=== VM created successfully! ==="
          echo ""
          echo "The VM is configured but not started."
          echo ""
          echo "To install NixOS:"
          echo "  1. Start VM: virsh start $VM_NAME"
          echo "  2. Watch progress: virt-viewer $VM_NAME"
          echo "  3. Installation will auto-run and power off when complete"
          echo ""
          echo "After installation completes:"
          echo "  1. Eject ISO: virsh change-media $VM_NAME sda --eject"
          echo "  2. Start VM: virsh start $VM_NAME"
          echo "  3. Connect: virt-viewer $VM_NAME"
          echo ""
          echo "To recreate VM: FORCE_RECREATE=1 nix run .#create-test-vm"
        '');
      };
    };
  };
}

#!/usr/bin/env bash
# Create a test VM using virt-install
# Usage: ./scripts/create-test-vm.sh
# Environment variables:
#   FORCE_RECREATE=1  - Delete and recreate existing VM

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_DIR="$(dirname "$SCRIPT_DIR")"

VM_NAME="test-vm"
VCPUS="4"
RAM="4096"
DISK_SIZE="40"
OVMF_CODE="/run/libvirt/nix-ovmf/OVMF_CODE.fd"
OVMF_VARS="/run/libvirt/nix-ovmf/OVMF_VARS.fd"

# Find the ISO
ISO_PATH=$(find "$FLAKE_DIR/result/test-vm-iso" -name "*.iso" -type f 2>/dev/null | head -1)

if [ -z "$ISO_PATH" ]; then
  echo "ERROR: ISO not found. Run './scripts/build-test-iso.sh' first."
  exit 1
fi

echo "Using ISO: $ISO_PATH"

# Check if VM already exists
if virsh dominfo "$VM_NAME" &>/dev/null; then
  if [ "${FORCE_RECREATE:-}" = "1" ]; then
    echo "Removing existing VM '$VM_NAME'..."
    virsh destroy "$VM_NAME" 2>/dev/null || true
    virsh undefine "$VM_NAME" --nvram --remove-all-storage 2>/dev/null || true
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
virt-install \
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
echo "To recreate VM: FORCE_RECREATE=1 $0"

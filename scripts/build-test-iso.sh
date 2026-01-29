#!/usr/bin/env bash
# Build the test-vm auto-install ISO
# Usage: ./scripts/build-test-iso.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_DIR="$(dirname "$SCRIPT_DIR")"

echo "Building test-vm ISO..."
echo "This may take a while on first build."
echo ""

cd "$FLAKE_DIR"

# Build the ISO
nix build ".#nixosConfigurations.test-vm-iso.config.system.build.isoImage" \
  --out-link result/test-vm-iso

ISO_PATH=$(find result/test-vm-iso -name "*.iso" -type f | head -1)

if [ -n "$ISO_PATH" ]; then
  echo ""
  echo "=== Build successful! ==="
  echo "ISO location: $ISO_PATH"
  echo ""
  echo "Next steps:"
  echo "  1. Run: ./scripts/create-test-vm.sh"
  echo "  2. Or use: nix run .#create-test-vm"
else
  echo "ERROR: ISO not found in result directory"
  exit 1
fi

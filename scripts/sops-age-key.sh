#!/usr/bin/env bash
# Fetch SOPS age key from Bitwarden and set up for use
#
# Usage:
#   eval $(./scripts/sops-age-key.sh)        # Set SOPS_AGE_KEY env var
#   ./scripts/sops-age-key.sh --install      # Install key to ~/.config/sops/age/

set -euo pipefail

BITWARDEN_ITEM="SOPS Age Key"
AGE_KEY_DIR="$HOME/.config/sops/age"
AGE_KEY_FILE="$AGE_KEY_DIR/keys.txt"

# Ensure rbw is unlocked
if ! rbw unlocked 2>/dev/null; then
    echo "Unlocking Bitwarden..." >&2
    rbw unlock
fi

# Fetch the key
AGE_KEY=$(rbw get "$BITWARDEN_ITEM" 2>/dev/null) || {
    echo "Error: Could not fetch '$BITWARDEN_ITEM' from Bitwarden" >&2
    echo "Create it first: rbw add '$BITWARDEN_ITEM'" >&2
    exit 1
}

case "${1:-}" in
    --install)
        # Install key to file system
        mkdir -p "$AGE_KEY_DIR"
        echo "$AGE_KEY" > "$AGE_KEY_FILE"
        chmod 600 "$AGE_KEY_FILE"
        echo "Age key installed to $AGE_KEY_FILE" >&2
        ;;
    --export)
        # Export for use with SOPS_AGE_KEY
        echo "export SOPS_AGE_KEY='$AGE_KEY'"
        ;;
    *)
        # Default: print the key
        echo "$AGE_KEY"
        ;;
esac

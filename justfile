update-vscode-insiders:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Fetching latest VSCode Insiders build for Linux x64..."
    URL='https://update.code.visualstudio.com/latest/linux-x64/insider'
    # Use the same name as in the nix file for clarity during prefetch
    HASH=$(nix-prefetch-url --quiet "$URL" --name vscode-insiders-linux-x64-latest.tar.gz)
    if [ -z "$HASH" ]; then
        echo "Error: Failed to fetch hash" >&2
        exit 1
    fi
    echo "Updating hash in home/vscode-insiders.nix..."
    # This sed command targets the specific placeholder sha and preserves the comment
    sed -i 's|sha256 = "0000000000000000000000000000000000000000000000000000"; # Placeholder|sha256 = "'"$HASH"'"; # Placeholder|' home/vscode-insiders.nix
    echo "Hash updated successfully in home/vscode-insiders.nix."
    echo "Please verify the change and rebuild your home-manager configuration."

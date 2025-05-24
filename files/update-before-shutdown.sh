#!/usr/bin/env bash
set -euo pipefail

cd /etc/nixos

# Update configuration repository
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  git pull --rebase
fi

# Determine flake host based on system hostname
case "$(hostname)" in
  mario-laptop)
    flake_host="laptop"
    ;;
  desktop)
    flake_host="desktop"
    ;;
  *)
    flake_host="nixos"
    ;;
esac

# Rebuild system with the latest configuration
nixos-rebuild switch --flake /etc/nixos#"${flake_host}"


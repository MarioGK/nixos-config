#!/usr/bin/env bash
set -euo pipefail

cd /etc/nixos

# Update configuration repository
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  if git diff-index --quiet HEAD --; then
    git pull --rebase
  else
    echo "Skipping git pull due to local changes"
  fi
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


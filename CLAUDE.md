# NixOS Configuration Repository

This repository contains a reproducible NixOS configuration using Nix Flakes for all my hardware.

## Repository Structure

```
nixos-config/
├── flake.nix              # Main flake definition with inputs and outputs
├── flake.lock             # Pinned dependency versions
├── hosts/                 # Machine-specific configurations
│   ├── desktop/           # Desktop workstation
│   └── laptop/            # Laptop configuration
├── modules/               # Reusable NixOS modules
│   ├── hardware/          # Hardware-specific settings
│   ├── profiles/          # Feature profiles (gaming, development, etc.)
│   └── services/          # System services
├── home/                  # Home Manager configurations
│   ├── programs/          # User program configs
│   └── desktop/           # Desktop environment settings
├── lib/                   # Helper functions (mkHost, etc.)
├── overlays/              # Package overlays
└── docs/                  # Documentation
```

## Quick Reference

### Fundamentals

| Topic | Documentation | Description |
|-------|---------------|-------------|
| Flakes Overview | [01-flakes-overview.md](docs/01-flakes-overview.md) | What flakes are, benefits, and how to enable them |
| Flake Structure | [02-flake-structure.md](docs/02-flake-structure.md) | Anatomy of flake.nix: inputs, outputs, and lock files |
| Module Organization | [03-module-organization.md](docs/03-module-organization.md) | Module patterns, mkHost helper, and specialArgs |

### Configuration

| Topic | Documentation | Description |
|-------|---------------|-------------|
| Home Manager | [04-home-manager.md](docs/04-home-manager.md) | User environment, dotfiles, and plasma-manager |
| Secrets Management | [05-secrets-management.md](docs/05-secrets-management.md) | sops-nix and agenix for secure secrets |
| Profile System | [10-profile-system.md](docs/10-profile-system.md) | Enabling development, gaming, multimedia profiles |

### Hardware & Graphics

| Topic | Documentation | Description |
|-------|---------------|-------------|
| GPU Configuration | [09-gpu-configuration.md](docs/09-gpu-configuration.md) | AMD/Intel drivers, Wayland, HDR setup |
| Power Management | [08-power-management.md](docs/08-power-management.md) | TLP, battery thresholds, CPU governors |
| Hardware Configs | [12-hardware-configs.md](docs/12-hardware-configs.md) | Adding hosts, Btrfs, nixos-generate-config |

### Desktop & Reference

| Topic | Documentation | Description |
|-------|---------------|-------------|
| Desktop Environment | [11-desktop-environment.md](docs/11-desktop-environment.md) | KDE Plasma 6, panels, shortcuts, theming |
| Best Practices | [06-best-practices.md](docs/06-best-practices.md) | Security, reproducibility, maintenance |
| Commands Reference | [07-commands-reference.md](docs/07-commands-reference.md) | nix, nixos-rebuild, home-manager CLI usage |

## Key Commands

### Rebuild System
```bash
# Apply configuration and switch immediately
sudo nixos-rebuild switch --flake .#hostname

# Build without switching (test build)
sudo nixos-rebuild build --flake .#hostname

# Apply on next boot
sudo nixos-rebuild boot --flake .#hostname
```

### Update Dependencies
```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake update nixpkgs

# Show current inputs
nix flake metadata
```

### Home Manager
```bash
# Switch home configuration (if standalone)
home-manager switch --flake .#username@hostname

# When integrated with NixOS, use nixos-rebuild
sudo nixos-rebuild switch --flake .#hostname
```

## Key Conventions

### Module Pattern
All modules use the standard NixOS module format:
```nix
{ config, lib, pkgs, ... }:
{
  options = { };
  config = { };
}
```

### Profile System
Features are organized into profiles that can be selectively enabled:
- `profiles/development.nix` - Development tools and languages
- `profiles/gaming.nix` - Gaming support (Steam, Gamemode, etc.)
- `profiles/multimedia.nix` - Audio/video production tools

### mkHost Helper
Host configurations use a helper function for consistency:
```nix
mkHost {
  hostname = "desktop";
  system = "x86_64-linux";
  profiles = [ gaming development ];
}
```

### Git Integration
**Important**: Always `git add` new files before rebuilding. Nix flakes only see tracked files.

```bash
git add new-module.nix
sudo nixos-rebuild switch --flake .#hostname
```

## Claude Instructions

Always use tasks (Task tool) and parallelize them whenever possible. When multiple independent operations need to be performed, launch them concurrently in a single message to maximize efficiency.

## External Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Reference Manual](https://nixos.org/manual/nix/stable/)
- [NixOS Wiki - Flakes](https://wiki.nixos.org/wiki/Flakes)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)

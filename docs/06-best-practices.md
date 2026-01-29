# Best Practices

## Security

### Never Store Secrets in Flakes

The Nix store is world-readable (`/nix/store/*` has 444 permissions).

```nix
# WRONG - visible in /nix/store
environment.etc."app/config".text = ''
  api_key = "sk-1234567890"
'';

# CORRECT - use sops-nix or agenix
sops.secrets.api-key = {};
services.myapp.apiKeyFile = config.sops.secrets.api-key.path;
```

See [Secrets Management](./05-secrets-management.md) for details.

### Use Minimal Permissions

```nix
systemd.services.myapp = {
  serviceConfig = {
    # Run as dedicated user, not root
    User = "myapp";
    Group = "myapp";

    # Restrict capabilities
    NoNewPrivileges = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;

    # Only allow specific paths
    ReadWritePaths = [ "/var/lib/myapp" ];
  };
};
```

### Keep System Minimal

Only install what you need:

```nix
{
  # Install system-wide only if multiple users need it
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
  ];

  # User-specific packages go in Home Manager
  home-manager.users.myuser = {
    home.packages = with pkgs; [
      discord
      spotify
    ];
  };
}
```

## Git Integration

### Always `git add` New Files

Flakes only see Git-tracked files. This is the most common "gotcha":

```bash
# Create new module
vim modules/new-feature.nix

# This will fail - file not tracked
sudo nixos-rebuild switch --flake .

# Fix: add to Git first
git add modules/new-feature.nix
sudo nixos-rebuild switch --flake .
```

### Structure Commits Logically

```bash
# Good: logical separation
git add modules/services/nginx.nix
git commit -m "Add nginx module"

git add hosts/webserver/default.nix
git commit -m "Configure webserver host"

# Less ideal: everything at once
git add -A
git commit -m "Add nginx and webserver"
```

### Use Branches for Experiments

```bash
# Test risky changes on a branch
git checkout -b experimental-feature
# ... make changes ...
sudo nixos-rebuild test --flake .  # Test without switching

# If it works
git checkout main
git merge experimental-feature
```

## Reproducibility

### Avoid Impure Builtins

These break reproducibility:

```nix
# AVOID - different results on different machines
builtins.currentTime
builtins.getEnv "HOME"
builtins.readFile "/etc/hostname"

# BETTER - explicit parameters
{ hostname, ... }:
{
  networking.hostName = hostname;  # Passed via specialArgs
}
```

### Pin Everything

```nix
# flake.nix
{
  inputs = {
    # Pin to specific branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # All inputs follow main nixpkgs
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Pin specific version if needed
    # nixpkgs.url = "github:NixOS/nixpkgs/abc123...";
  };
}
```

### Lock File Hygiene

```bash
# Commit flake.lock
git add flake.lock
git commit -m "Update flake inputs"

# Update incrementally
nix flake update nixpkgs
# Test
sudo nixos-rebuild test --flake .
# Then update others
nix flake update home-manager
```

## Multi-Architecture Support

Use flake-utils for cleaner multi-arch support:

```nix
{
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.hello;
        devShells.default = pkgs.mkShell { };
      }
    ) // {
      # NixOS configs outside eachDefaultSystem
      nixosConfigurations = { };
    };
}
```

## Overlays

### Mixing Stable and Unstable

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${system};
      };
    in
    {
      nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ ... }: {
            nixpkgs.overlays = [ overlay-unstable ];
          })
          ./configuration.nix
        ];
      };
    };
}
```

```nix
# configuration.nix
{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.vim                    # From stable
    pkgs.unstable.neovim        # From unstable
  ];
}
```

### Custom Package Modifications

```nix
# overlays/default.nix
final: prev: {
  # Override package
  htop = prev.htop.overrideAttrs (old: {
    patches = (old.patches or []) ++ [ ./htop-custom.patch ];
  });

  # Add package from different source
  my-package = final.callPackage ../packages/my-package.nix {};
}
```

## Development Shells

### With direnv

```nix
# flake.nix
{
  outputs = { nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with pkgs; [
          nodejs
          nodePackages.npm
          python3
        ];

        shellHook = ''
          echo "Dev environment ready!"
          export PROJECT_ROOT=$(pwd)
        '';
      };
    };
}
```

```bash
# .envrc
use flake
```

```nix
# In NixOS config, enable direnv
programs.direnv = {
  enable = true;
  nix-direnv.enable = true;
};
```

### Per-Language Shells

```nix
{
  devShells.x86_64-linux = {
    default = pkgs.mkShell { };

    rust = pkgs.mkShell {
      packages = with pkgs; [ rustc cargo rust-analyzer ];
    };

    python = pkgs.mkShell {
      packages = with pkgs; [ python3 python3Packages.pip ];
    };

    node = pkgs.mkShell {
      packages = with pkgs; [ nodejs nodePackages.npm ];
    };
  };
}
```

## Profile System Pattern

Organize features into toggleable profiles:

```nix
# modules/profiles/gaming.nix
{ config, lib, pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    protonup-qt
  ];

  # 32-bit support for games
  hardware.graphics.enable32Bit = true;
}
```

```nix
# modules/profiles/development.nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    gh
    docker-compose
  ];

  virtualisation.docker.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
```

```nix
# hosts/desktop/default.nix
{ ... }:
{
  imports = [
    ../../modules/profiles/gaming.nix
    ../../modules/profiles/development.nix
  ];
}
```

## Dendritic Pattern

For multi-platform configurations or when you want maximum flexibility,
adopt the Dendritic Pattern:

- Organize by features, not by configuration type
- Use flake-parts as the top-level configuration
- Auto-import modules with import-tree
- Avoid specialArgs - use options instead

See [Dendritic Pattern](./13-dendritic-pattern.md) for implementation details.

## Wayland Configuration

```nix
{ pkgs, ... }:
{
  # Use Wayland-native display manager
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # KDE Plasma with Wayland
  services.desktopManager.plasma6.enable = true;

  # Environment variables for Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";  # Electron apps
    MOZ_ENABLE_WAYLAND = "1";  # Firefox
  };

  # XWayland for compatibility
  programs.xwayland.enable = true;
}
```

## Systemd Services Pattern

### Update on Shutdown

```nix
{ pkgs, ... }:
{
  systemd.services.update-on-shutdown = {
    description = "Update system on shutdown";
    wantedBy = [ "halt.target" "reboot.target" ];
    before = [ "halt.target" "reboot.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      ${pkgs.nix}/bin/nix flake update /etc/nixos
    '';
  };
}
```

### Scheduled Maintenance

```nix
{
  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Optimize store
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
}
```

## Further Reading

- [NixOS Wiki - Security](https://wiki.nixos.org/wiki/Security)
- [NixOS Hardening Guide](https://xeiaso.net/blog/paranoid-nixos-2021-07-18/)
- [Determinate Systems Best Practices](https://determinate.systems/posts/nix-best-practices)

# Dendritic Pattern

The Dendritic Pattern is an advanced Nix configuration methodology that provides maximum flexibility through feature-centric organization. This document serves as a reference for writing new configuration code.

## Introduction

Traditional Nix configurations organize by configuration type (NixOS modules, Home Manager, etc.) with host-centric hierarchies. The Dendritic Pattern inverts this: every file is a top-level module, organized by feature rather than by config type.

Key characteristics:
- **Every file is a flake-parts module** imported directly at the top level
- **Feature-centric organization** groups all code for a capability in one place
- **No specialArgs** - values are shared via flake-parts options instead
- **Automatic imports** via import-tree eliminate manual import lists

## Core Principles

### Every File is a Top-Level Module

In the Dendritic Pattern, there are no nested imports. Every `.nix` file in your configuration is a flake-parts module that gets imported at the top level:

```nix
# Every file follows this structure
{ ... }:
{
  # flake-parts module content
}
```

This eliminates the traditional hierarchy where hosts import modules which import other modules.

### Feature-Centric Organization

Instead of organizing by config type:

```
# Traditional (config-type centric)
modules/
  nixos/
    networking.nix
    users.nix
  home-manager/
    git.nix
    shell.nix
hosts/
  desktop/
  laptop/
```

Organize by feature:

```
# Dendritic (feature-centric)
features/
  development/
    git.nix        # Both NixOS and HM config for git
    editors.nix    # All editor configuration
  networking/
    tailscale.nix  # Service + firewall + user config
  desktop/
    plasma.nix     # DE config across all levels
```

### Automatic Imports with import-tree

The `import-tree` library automatically imports all modules from a directory:

```nix
# flake.nix
{
  inputs.import-tree.url = "github:vic/import-tree";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        (inputs.import-tree inputs ./features)
      ];
    };
}
```

Every `.nix` file under `./features/` becomes a flake-parts module automatically.

### No specialArgs Anti-Pattern

Traditional configs pass values through `specialArgs`:

```nix
# Traditional - avoid this
specialArgs = { inherit inputs hostname; };
```

The Dendritic Pattern uses flake-parts options instead:

```nix
# Define options at flake level
options.myConfig.hostname = lib.mkOption { type = lib.types.str; };

# Access anywhere via config
config.myConfig.hostname
```

## Benefits

### Flexible File Organization

Files can be organized however makes sense for your workflow. Add, remove, or reorganize files without updating import lists.

### Self-Contained Features

Each feature file contains everything for that capability:
- NixOS configuration
- Home Manager configuration
- Package overlays
- Custom options

### Reduced Boilerplate

No need to maintain import lists, pass specialArgs through layers, or wire up modules manually.

### Multi-Platform Coherence

Features work across different platforms (NixOS, Darwin, home-manager standalone) because everything is defined at the flake level.

## Implementation

### Adding Required Inputs

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    import-tree.url = "github:vic/import-tree";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

### Minimal flake.nix Structure

```nix
{
  inputs = { /* ... */ };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];

      imports = [
        (inputs.import-tree inputs ./nix)
      ];
    };
}
```

### Module File Format

Every file is a flake-parts module:

```nix
# nix/features/development.nix
{ lib, config, inputs, ... }:
{
  # Define custom options
  options.myConfig.development.enable = lib.mkEnableOption "development tools";

  # Configure based on options
  config = lib.mkIf config.myConfig.development.enable {
    # flake-parts configuration here
  };
}
```

### Using deferredModule for Lower-Level Configs

For NixOS or Home Manager configuration, use `deferredModule`:

```nix
# nix/features/git.nix
{ lib, config, ... }:
{
  options.myConfig.git.enable = lib.mkEnableOption "git configuration";

  config = lib.mkIf config.myConfig.git.enable {
    # NixOS module (deferred)
    flake.nixosModules.git = { pkgs, ... }: {
      programs.git.enable = true;
      environment.systemPackages = [ pkgs.git pkgs.gh ];
    };

    # Home Manager module (deferred)
    flake.homeModules.git = { pkgs, ... }: {
      programs.git = {
        enable = true;
        userName = "Your Name";
        userEmail = "you@example.com";
      };
    };
  };
}
```

### Defining NixOS Configurations

```nix
# nix/hosts/desktop.nix
{ inputs, config, ... }:
{
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      config.flake.nixosModules.git
      config.flake.nixosModules.development
      ./desktop/hardware-configuration.nix
      {
        networking.hostName = "desktop";
      }
    ];
  };
}
```

## Example: Complete Feature Module

```nix
# nix/features/tailscale.nix
{ lib, config, inputs, ... }:

let
  cfg = config.myConfig.tailscale;
in
{
  options.myConfig.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN";
    authKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to auth key file";
    };
  };

  config = lib.mkIf cfg.enable {
    # NixOS service configuration
    flake.nixosModules.tailscale = { pkgs, ... }: {
      services.tailscale = {
        enable = true;
        authKeyFile = cfg.authKeyFile;
      };

      networking.firewall = {
        trustedInterfaces = [ "tailscale0" ];
        allowedUDPPorts = [ 41641 ];
      };

      environment.systemPackages = [ pkgs.tailscale ];
    };
  };
}
```

## Migration Notes

The existing repository structure does not need to change. This documentation serves as a reference for writing new code. When adding new features:

1. Consider if the feature would benefit from dendritic organization
2. Keep related NixOS and Home Manager config together
3. Use flake-parts options instead of specialArgs for new code
4. Document feature modules clearly

## Further Reading

- [Dendritic Pattern](https://github.com/mightyiam/dendritic) - Pattern specification and rationale
- [import-tree](https://github.com/vic/import-tree) - Automatic module importing
- [Dendrix](https://github.com/vic/dendrix) - Full dendritic configuration template
- [flake-parts](https://flake.parts/) - Modular flake framework

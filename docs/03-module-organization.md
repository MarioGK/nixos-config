# Module Organization

## NixOS Module Basics

A NixOS module is a file that can define options and configure the system. Every module follows this structure:

```nix
{ config, lib, pkgs, ... }:
{
  imports = [
    # Other modules to include
  ];

  options = {
    # Custom options this module provides
  };

  config = {
    # Configuration values
  };
}
```

### Simplified Form

For modules that only set configuration (no custom options):

```nix
{ config, lib, pkgs, ... }:
{
  # These are implicitly under `config`
  environment.systemPackages = [ pkgs.vim ];
  services.nginx.enable = true;
}
```

## Using Imports

### Basic Imports

```nix
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./services/nginx.nix
    ./users.nix
  ];
}
```

### Conditional Imports

```nix
{ lib, ... }:
{
  imports = [
    ./base.nix
  ] ++ lib.optionals (builtins.pathExists ./local.nix) [
    ./local.nix
  ];
}
```

### Function Imports

Modules can be functions that take arguments:

```nix
# In flake.nix
modules = [
  (import ./modules/my-module.nix { inherit someArg; })
];
```

## Priority Functions

Control how values merge when multiple modules set the same option.

### mkDefault

Lowest priority—easily overridden:

```nix
{ lib, ... }:
{
  # Can be overridden by any other module
  services.openssh.settings.PermitRootLogin = lib.mkDefault "no";
}
```

### mkForce

Highest priority—overrides everything:

```nix
{ lib, ... }:
{
  # Overrides all other values
  networking.firewall.enable = lib.mkForce true;
}
```

### mkOverride

Explicit priority (lower number = higher priority):

```nix
{ lib, ... }:
{
  # Default is 100, mkDefault is 1000, mkForce is 50
  some.option = lib.mkOverride 75 "value";
}
```

### mkBefore / mkAfter

For list options, control ordering:

```nix
{ lib, ... }:
{
  environment.systemPackages = lib.mkBefore [ pkgs.essential ];
  # or
  environment.systemPackages = lib.mkAfter [ pkgs.optional ];
}
```

### mkMerge

Combine multiple definitions:

```nix
{ lib, ... }:
{
  services.nginx = lib.mkMerge [
    { enable = true; }
    (lib.mkIf config.services.myapp.enable {
      virtualHosts."myapp" = { ... };
    })
  ];
}
```

## Recommended Directory Structure

```
nixos-config/
├── flake.nix
├── flake.lock
│
├── lib/                      # Helper functions
│   └── default.nix           # mkHost and other utilities
│
├── modules/                  # Reusable NixOS modules
│   ├── hardware/             # Hardware-specific
│   │   ├── nvidia.nix
│   │   ├── amd.nix
│   │   └── bluetooth.nix
│   │
│   ├── profiles/             # Feature profiles
│   │   ├── development.nix   # Dev tools, languages
│   │   ├── gaming.nix        # Steam, gamemode, etc.
│   │   └── multimedia.nix    # Audio/video production
│   │
│   └── services/             # Service configurations
│       ├── docker.nix
│       └── tailscale.nix
│
├── hosts/                    # Machine-specific configs
│   ├── desktop/
│   │   ├── default.nix       # Main configuration
│   │   └── hardware-configuration.nix
│   │
│   └── laptop/
│       ├── default.nix
│       └── hardware-configuration.nix
│
├── home/                     # Home Manager configs
│   ├── default.nix
│   ├── programs/
│   │   ├── git.nix
│   │   ├── shell.nix
│   │   └── editor.nix
│   └── desktop/
│       └── plasma.nix
│
└── overlays/                 # Package overlays
    └── default.nix
```

## specialArgs

Pass custom arguments to all modules:

```nix
# In flake.nix
nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";

  specialArgs = {
    inherit inputs;          # Pass flake inputs
    hostname = "myhost";     # Custom values
    isDesktop = true;
  };

  modules = [ ./hosts/myhost ];
};
```

```nix
# In any module, these are available:
{ config, lib, pkgs, inputs, hostname, isDesktop, ... }:
{
  networking.hostName = hostname;

  services.xserver.enable = isDesktop;
}
```

## mkHost Helper Pattern

Create a helper function for consistent host definitions:

```nix
# lib/default.nix
{ inputs, ... }:

{
  mkHost = {
    hostname,
    system ? "x86_64-linux",
    profiles ? [],
    extraModules ? []
  }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs hostname;
      };

      modules = [
        # Base configuration
        ../modules/base.nix

        # Host-specific configuration
        ../hosts/${hostname}

        # Home Manager
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ]
      ++ profiles
      ++ extraModules;
    };
}
```

```nix
# flake.nix
{
  outputs = { self, nixpkgs, ... }@inputs:
    let
      lib = import ./lib { inherit inputs; };
    in
    {
      nixosConfigurations = {
        desktop = lib.mkHost {
          hostname = "desktop";
          profiles = [
            ./modules/profiles/gaming.nix
            ./modules/profiles/development.nix
          ];
        };

        laptop = lib.mkHost {
          hostname = "laptop";
          profiles = [
            ./modules/profiles/development.nix
          ];
          extraModules = [
            ./modules/hardware/laptop-power.nix
          ];
        };
      };
    };
}
```

## Custom Options

Define your own options for reusable modules:

```nix
# modules/services/myapp.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.services.myapp;
in
{
  options.services.myapp = {
    enable = lib.mkEnableOption "MyApp service";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to listen on";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "myapp";
      description = "User to run as";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.myapp = {
      description = "MyApp Service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.myapp}/bin/myapp --port ${toString cfg.port}";
        User = cfg.user;
      };
    };

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.user;
    };
    users.groups.${cfg.user} = {};
  };
}
```

## Further Reading

- [NixOS Manual - Writing Modules](https://nixos.org/manual/nixos/stable/#sec-writing-modules)
- [NixOS Wiki - Module](https://wiki.nixos.org/wiki/NixOS_modules)
- [Nix Pills - NixOS Modules](https://nixos.org/guides/nix-pills/nixos-modules.html)

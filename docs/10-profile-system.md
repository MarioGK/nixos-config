# Profile System

This guide explains the profile system used to organize and enable feature sets across different hosts.

## Overview

Profiles are reusable configuration modules that group related packages and settings. Instead of duplicating configuration across hosts, profiles provide a clean way to enable feature sets.

## Profile Architecture

```
nixos-config/
├── modules/
│   └── profiles.nix     # Profile option definitions
├── profiles/
│   ├── laptop.nix       # Laptop-specific profile
│   └── desktop.nix      # Desktop-specific profile
└── hosts/
    ├── laptop/          # Imports profiles/laptop.nix
    └── desktop/         # Imports profiles/desktop.nix
```

## Defining Profile Options

Profile options are defined in `modules/profiles.nix`:

```nix
# modules/profiles.nix
{ config, lib, pkgs, ... }:
{
  options.profiles = {
    development = lib.mkEnableOption "Development tools and languages";
    gaming = lib.mkEnableOption "Gaming support and tools";
    multimedia = lib.mkEnableOption "Audio/video production tools";
    laptop-specific = lib.mkEnableOption "Laptop optimizations";
    desktop-specific = lib.mkEnableOption "Desktop workstation tools";
  };

  config = {
    # Development profile
    environment.systemPackages = lib.mkIf config.profiles.development (with pkgs; [
      git
      wget
      nano
      htop
      btop
      zoxide
      nixfmt-rfc-style
    ]);

    # Gaming profile
    environment.systemPackages = lib.mkIf config.profiles.gaming (with pkgs; [
      vulkan-tools
      libva-utils
      wayland-utils
    ]);

    # Multimedia profile
    environment.systemPackages = lib.mkIf config.profiles.multimedia (with pkgs; [
      pavucontrol
      pamixer
    ]);

    # Laptop-specific profile
    environment.systemPackages = lib.mkIf config.profiles.laptop-specific (with pkgs; [
      powertop
    ]);

    # Desktop-specific profile
    environment.systemPackages = lib.mkIf config.profiles.desktop-specific (with pkgs; [
      lact
      radeontop
    ]);
  };
}
```

## Using Profiles

### In Host Profiles

Enable profiles in your host-specific profile file:

```nix
# profiles/laptop.nix
{ config, lib, pkgs, ... }:
{
  imports = [
    ../modules/tlp.nix
  ];

  # Enable desired profiles
  profiles = {
    development = true;
    multimedia = true;
    laptop-specific = true;
    gaming = true;
  };

  # Additional laptop-specific configuration
  powerManagement.enable = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
    ];
  };
}
```

```nix
# profiles/desktop.nix
{ config, lib, pkgs, ... }:
{
  profiles = {
    development = true;
    multimedia = true;
    desktop-specific = true;
    gaming = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}
```

### In Host Configurations

Host configurations import their respective profiles:

```nix
# hosts/laptop/default.nix
{ config, pkgs, ... }:
{
  imports = [
    ../../profiles/laptop.nix
    ../../hardware/laptop.nix
  ];

  # Host-specific overrides only
  networking.hostName = "mario-laptop";
}
```

## Creating Custom Profiles

### Step 1: Add Option Definition

```nix
# In modules/profiles.nix
options.profiles = {
  # ... existing options ...

  virtualization = lib.mkEnableOption "Virtualization tools (VMs, containers)";
};
```

### Step 2: Add Configuration

```nix
# In modules/profiles.nix config section
config = {
  # ... existing configs ...

  # Virtualization profile
  virtualisation = lib.mkIf config.profiles.virtualization {
    libvirtd.enable = true;
    docker.enable = true;
  };

  environment.systemPackages = lib.mkIf config.profiles.virtualization (with pkgs; [
    virt-manager
    docker-compose
  ]);
};
```

### Step 3: Enable in Host Profile

```nix
# profiles/desktop.nix
{
  profiles = {
    development = true;
    virtualization = true;  # New profile
  };
}
```

## Profile Composition

Profiles can be composed and combined:

```nix
# A "workstation" profile that combines others
# profiles/workstation.nix
{ config, lib, pkgs, ... }:
{
  imports = [
    ./desktop.nix
  ];

  profiles = {
    development = true;
    virtualization = true;
    multimedia = true;
  };

  # Workstation-specific additions
  services.printing.enable = true;
}
```

## Best Practices

### 1. Keep Profiles Focused

Each profile should have a single responsibility:
- **Good**: `profiles.gaming` - Only gaming-related packages
- **Bad**: `profiles.gaming` - Gaming + streaming + video editing

### 2. Use lib.mkIf for Conditional Config

```nix
# Correct - configuration only applied when profile is enabled
environment.systemPackages = lib.mkIf config.profiles.gaming [ ... ];

# Avoid - always applies regardless of profile
environment.systemPackages = [ ... ];
```

### 3. Document Profile Dependencies

```nix
# profiles/streaming.nix
{ config, lib, pkgs, ... }:
{
  # This profile requires multimedia profile
  assertions = [{
    assertion = config.profiles.multimedia;
    message = "Streaming profile requires multimedia profile to be enabled";
  }];

  profiles.multimedia = lib.mkDefault true;  # Auto-enable dependency
}
```

### 4. Use mkDefault for Overridable Defaults

```nix
profiles = {
  development = lib.mkDefault true;  # Can be overridden
  gaming = true;                      # Cannot be easily overridden
};
```

## Listing Active Profiles

Check which profiles are enabled on your system:

```bash
# In nix repl
nix repl
:lf .
nixosConfigurations.laptop.config.profiles
```

## Related Documentation

- [Module Organization](03-module-organization.md) - Module structure and patterns
- [Hardware Configs](12-hardware-configs.md) - Host-specific hardware setup
- [Best Practices](06-best-practices.md) - Configuration best practices

# GPU Configuration

This guide covers graphics card setup for AMD and Intel GPUs, including drivers, Wayland support, and HDR configuration.

## Overview

NixOS supports various GPU configurations through the `hardware.graphics` (formerly `hardware.opengl`) module. This repository uses Wayland exclusively with KDE Plasma 6.

## AMD GPU Configuration

### Basic Setup

```nix
# profiles/desktop.nix
{ config, lib, pkgs, ... }:
{
  # Enable 32-bit graphics support (for Steam, Wine, etc.)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk              # AMD Vulkan driver
      vaapiVdpau          # VA-API to VDPAU bridge
      libvdpau-va-gl      # VDPAU to VA-API bridge
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      amdvlk
    ];
  };
}
```

### Driver Options

| Driver | Description | Use Case |
|--------|-------------|----------|
| `amdvlk` | AMD's official Vulkan driver | Better compatibility, some games prefer it |
| `radv` (Mesa) | Open-source Vulkan (default) | Generally better performance |
| `amdgpu` | Kernel driver | Automatically loaded |

### Selecting Vulkan Driver

Force a specific Vulkan driver:
```bash
# Use AMD's proprietary driver
AMD_VULKAN_ICD=AMDVLK game-executable

# Use Mesa's RADV (default)
AMD_VULKAN_ICD=RADV game-executable
```

### GPU Monitoring Tools

```nix
environment.systemPackages = with pkgs; [
  radeontop    # AMD GPU monitor (like htop for GPU)
  lact         # Linux AMDGPU Controller (GUI)
];
```

## Intel GPU Configuration

### Basic Setup

```nix
# profiles/laptop.nix
{ config, lib, pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver    # Modern Intel GPUs (Broadwell+)
      intel-compute-runtime # OpenCL support
    ];
  };

  # Additional Intel packages
  environment.systemPackages = with pkgs; [
    nvtopPackages.intel   # GPU monitor for Intel
  ];
}
```

### Driver Selection

| Driver | Description | Hardware |
|--------|-------------|----------|
| `intel-media-driver` | Modern VA-API driver | Broadwell (2014) and newer |
| `intel-vaapi-driver` | Legacy VA-API driver | Older Intel GPUs |
| `intel-compute-runtime` | OpenCL/Level Zero | Compute workloads |

### Environment Variables

```nix
environment.sessionVariables = {
  LIBVA_DRIVER_NAME = "iHD";  # Use intel-media-driver
};
```

## HDR Configuration

### KWin HDR Setup

Enable HDR in KDE Plasma with KWin:

```nix
# In home-manager configuration
programs.plasma.kwin = {
  # HDR settings
  "Effect-overview" = {
    BorderActivate = 9;
  };
};

# KWinrc configuration
home.file.".config/kwinrc".text = ''
  [Plugins]
  blurEnabled=true

  [Compositing]
  MaxFPS=120          # or 144 for desktop

  [Xwayland]
  Scale=1

  [NightLight]
  Active=false
'';
```

### Per-Host HDR Configuration

```nix
# Desktop: 144 FPS HDR
# profiles/desktop.nix
xdg.configFile."kwinrc".text = ''
  [Compositing]
  MaxFPS=144
'';

# Laptop: 120 FPS HDR
# profiles/laptop.nix
xdg.configFile."kwinrc".text = ''
  [Compositing]
  MaxFPS=120
'';
```

## Wayland Configuration

### Force Wayland for Applications

```nix
environment.sessionVariables = {
  NIXOS_OZONE_WL = "1";           # Electron apps
  MOZ_ENABLE_WAYLAND = "1";       # Firefox
  QT_QPA_PLATFORM = "wayland";    # Qt apps
  GDK_BACKEND = "wayland";        # GTK apps
};
```

### SDDM Wayland

```nix
services.displayManager.sddm = {
  enable = true;
  wayland.enable = true;
};
```

## Video Acceleration

### VA-API Testing

```bash
# Check VA-API support
vainfo

# Check VDPAU support
vdpauinfo
```

### Hardware Video Decoding

Ensure video players use hardware acceleration:

```nix
environment.systemPackages = with pkgs; [
  libva-utils   # vainfo command
  vulkan-tools  # vulkaninfo command
];
```

## Troubleshooting

### Black Screen After Boot

Try kernel mode setting:
```nix
boot.initrd.kernelModules = [ "amdgpu" ];  # or "i915" for Intel
```

### Screen Tearing

Ensure compositor is running:
```bash
# Check KWin compositor
qdbus org.kde.KWin /Compositor active
```

### Wrong GPU Being Used (Hybrid Laptops)

For laptops with dual GPUs:
```nix
hardware.nvidia.prime = {
  offload.enable = true;
  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:1:0:0";
};
```

## Related Documentation

- [Hardware Configs](12-hardware-configs.md) - Host-specific hardware setup
- [Desktop Environment](11-desktop-environment.md) - KDE Plasma configuration
- [Best Practices](06-best-practices.md) - Wayland best practices

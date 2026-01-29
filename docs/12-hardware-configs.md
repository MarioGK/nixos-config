# Hardware Configurations

This guide covers host-specific hardware setup, nixos-generate-config usage, filesystem configuration, and adding new hosts.

## Overview

Hardware configurations define machine-specific settings like boot parameters, filesystems, and kernel modules. Each host has its own hardware configuration that rarely changes.

## Directory Structure

```
nixos-config/
├── hardware/
│   ├── laptop.nix      # Laptop hardware config
│   └── desktop.nix     # Desktop hardware config
├── hosts/
│   ├── laptop/
│   │   └── default.nix # Imports hardware + profile
│   └── desktop/
│       └── default.nix
└── flake.nix
```

## Generating Hardware Configuration

Use `nixos-generate-config` to create initial hardware configuration:

```bash
# Generate configuration for current system
sudo nixos-generate-config --show-hardware-config > hardware/new-host.nix
```

This outputs detected:
- Kernel modules for initrd and boot
- Filesystem mounts
- CPU type and microcode
- Swap configuration

## Hardware Configuration Example

### Laptop (Intel-based)

```nix
# hardware/laptop.nix
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Kernel modules
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Filesystems
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/XXXX-XXXX";
    fsType = "vfat";
  };

  # Swap
  swapDevices = [{
    device = "/swap/swapfile";
    size = 48 * 1024;  # 48GB
  }];

  # CPU
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Networking
  networking.useDHCP = lib.mkDefault true;
}
```

### Desktop (AMD-based)

```nix
# hardware/desktop.nix
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Filesystems
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/XXXX-XXXX";
    fsType = "vfat";
  };

  swapDevices = [{
    device = "/swap/swapfile";
    size = 48 * 1024;
  }];

  # CPU
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  # 32-bit support for gaming
  hardware.graphics.enable32Bit = true;
}
```

## Btrfs Configuration

### Recommended Subvolume Layout

```
/dev/nvme0n1p2 (btrfs)
├── @           → /
├── @home       → /home
├── @nix        → /nix
├── @log        → /var/log
└── @snapshots  → /.snapshots
```

### Mount Options

```nix
fileSystems."/" = {
  device = "/dev/disk/by-uuid/...";
  fsType = "btrfs";
  options = [
    "subvol=@"
    "compress=zstd"    # Compression
    "noatime"          # Performance
    "ssd"              # SSD optimizations
    "space_cache=v2"   # Better caching
  ];
};
```

## Adding a New Host

### Step 1: Generate Hardware Config

```bash
# On the new machine
sudo nixos-generate-config --show-hardware-config > /tmp/hardware.nix

# Copy to your config repo
cp /tmp/hardware.nix hardware/newhost.nix
```

### Step 2: Create Host Directory

```nix
# hosts/newhost/default.nix
{ config, pkgs, ... }:
{
  imports = [
    ../../hardware/newhost.nix
    ../../profiles/desktop.nix  # or laptop.nix
  ];

  networking.hostName = "newhost";
}
```

### Step 3: Add to flake.nix

```nix
# flake.nix
{
  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # Existing hosts...

      newhost = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./modules/base.nix
          ./modules/profiles.nix
          ./hosts/newhost
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
```

### Step 4: Build and Switch

```bash
git add hardware/newhost.nix hosts/newhost/
sudo nixos-rebuild switch --flake .#newhost
```

## Using nixos-hardware

For common hardware, use the nixos-hardware flake:

```nix
# flake.nix
{
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  outputs = { nixos-hardware, ... }: {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      modules = [
        nixos-hardware.nixosModules.lenovo-thinkpad-e14-gen6
        ./hosts/laptop
      ];
    };
  };
}
```

Available modules include ThinkPads, Dell XPS, Framework, and many more.

## Boot Configuration

### Systemd-boot (Recommended)

```nix
# modules/base.nix
boot = {
  loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;  # Keep last 10 generations
    };
    efi.canTouchEfiVariables = true;
  };

  # Use latest kernel
  kernelPackages = pkgs.linuxPackages_latest;
};
```

### Kernel Parameters

```nix
boot.kernelParams = [
  "quiet"
  "splash"
  "nowatchdog"  # Disable watchdog for faster boot
];
```

## Firmware

### Enable Redistributable Firmware

```nix
hardware.enableRedistributableFirmware = true;
```

### Specific Firmware Packages

```nix
hardware.firmware = with pkgs; [
  linux-firmware
  sof-firmware        # Sound Open Firmware
  alsa-firmware       # ALSA firmware
];
```

## Troubleshooting

### Boot Fails After Hardware Change

Boot from previous generation:
```bash
# At boot menu, select older generation
# Then rebuild with updated hardware config
sudo nixos-generate-config --show-hardware-config > hardware/laptop.nix
sudo nixos-rebuild switch --flake .#laptop
```

### Missing Kernel Modules

Check what modules are needed:
```bash
lspci -k  # Shows kernel driver in use
lsmod     # Lists loaded modules
```

### Filesystem Not Mounting

Verify UUIDs:
```bash
blkid
ls -la /dev/disk/by-uuid/
```

## Related Documentation

- [Flake Structure](02-flake-structure.md) - Adding hosts to flake.nix
- [Module Organization](03-module-organization.md) - mkHost helper usage
- [Profile System](10-profile-system.md) - Selecting profiles for new hosts

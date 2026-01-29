# TEMPLATE: Replace this file with output from:
# nixos-generate-config --show-hardware-config
#
# Run this on the desktop machine to get the actual UUIDs and hardware configuration

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Boot modules - amdgpu is loaded via amd-desktop.nix
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Filesystem configuration
  # TODO: Replace UUIDs with actual values from hardware
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-ROOT-UUID";
    fsType = "ext4";  # or "btrfs" if using Btrfs
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-BOOT-UUID";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # Swap configuration
  # Option 1: Swap partition
  # swapDevices = [
  #   { device = "/dev/disk/by-uuid/REPLACE-WITH-SWAP-UUID"; }
  # ];

  # Option 2: zram swap (recommended for 32GB RAM)
  zramSwap = {
    enable = true;
    memoryPercent = 25;  # 8GB of compressed swap
  };

  # Hardware detection
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
}

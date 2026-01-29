# Hardware configuration for Lenovo ThinkPad (AMD Ryzen)
#
# This file should be generated with `nixos-generate-config --show-hardware-config`
# on the target machine and then updated with the correct UUIDs.
#
# IMPORTANT: Replace the placeholder UUIDs below with actual values from your system.
# Run `lsblk -f` to find your partition UUIDs.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Boot configuration
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # LUKS encrypted root partition
  # Replace <LUKS-UUID> with actual UUID from `lsblk -f`
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/<LUKS-UUID>";
    preLVM = true;
    allowDiscards = true;
    # TPM2 auto-unlock - uncomment after enrolling:
    # crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  # Filesystems
  # Replace UUIDs with actual values from `lsblk -f`
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/<ROOT-UUID>";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/<ROOT-UUID>";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/<ROOT-UUID>";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd" "noatime" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/<ROOT-UUID>";
    fsType = "btrfs";
    options = [ "subvol=@log" "compress=zstd" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/<BOOT-UUID>";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # Swap (if using swap partition or file)
  # swapDevices = [ { device = "/dev/disk/by-uuid/<SWAP-UUID>"; } ];

  # Swap file alternative (recommended for LUKS)
  swapDevices = [ ];

  # CPU and hardware detection
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

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

  # Root filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/bfd2a77e-3190-4aa6-bdf3-65c4f20809e0";
    fsType = "ext4";
  };

  # Boot partition
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6C39-C366";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # Secondary drives
  fileSystems."/mnt/BigData" = {
    device = "/dev/disk/by-uuid/9a7ca9a4-0d33-4532-b489-18c797600eee";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  fileSystems."/mnt/FastData" = {
    device = "/dev/disk/by-uuid/b156985e-0a5f-4406-90cf-e76b892062e1";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  # Hardware detection
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
}

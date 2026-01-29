{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Boot (virtio)
  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" "virtio_blk" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" ];  # or kvm-amd depending on host

  # Filesystems - replace UUIDs after VM creation
  # Run: nixos-generate-config --show-hardware-config
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-ROOT-UUID";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE-BOOT-UUID";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # zram swap
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

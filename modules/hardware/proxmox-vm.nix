{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  # QEMU guest agent for Proxmox integration
  services.qemuGuest.enable = true;

  # Virtio drivers for performance
  boot.initrd.availableKernelModules = [
    "virtio_pci" "virtio_scsi" "virtio_blk" "virtio_net"
    "ahci" "sd_mod" "sr_mod"
  ];

  # Console for Proxmox serial access
  boot.kernelParams = [ "console=ttyS0,115200" ];

  # Filesystem trim support for thin-provisioned disks
  services.fstrim.enable = true;
}

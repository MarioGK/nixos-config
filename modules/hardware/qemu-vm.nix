# Hardware configuration for QEMU/KVM virtual machine (graphical)
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  # QEMU guest agent for hypervisor integration (shutdown, freeze, etc.)
  services.qemuGuest.enable = true;

  # QXL video driver for better VM performance
  services.xserver.videoDrivers = [ "qxl" ];

  # VirtIO drivers
  boot.initrd.kernelModules = [ "virtio_gpu" ];

  # Basic graphics
  hardware.graphics = {
    enable = true;
  };

  # No power management needed in VM
  services.tlp.enable = lib.mkForce false;
  services.power-profiles-daemon.enable = false;

  # Filesystem trim support for thin-provisioned disks
  services.fstrim.enable = true;
}

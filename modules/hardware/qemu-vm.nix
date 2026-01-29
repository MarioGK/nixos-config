# Hardware configuration for QEMU/KVM virtual machine (graphical)
{ config, lib, pkgs, ... }:

{
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
}

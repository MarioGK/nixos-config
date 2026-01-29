# Hardware configuration for QEMU/KVM virtual machine (graphical)
{ config, lib, ... }:

{
  flake.modules.nixos.hardware-qemu-vm = { config, lib, pkgs, modulesPath, ... }: {
    imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

    # Default filesystem configuration for test VMs
    # These are placeholders that work with qemu-vm.nix
    fileSystems."/" = lib.mkDefault {
      device = "/dev/vda1";
      fsType = "ext4";
    };

    # Bootloader configuration for VM
    boot.loader.grub = lib.mkDefault {
      enable = true;
      device = "/dev/vda";
    };
    boot.loader.systemd-boot.enable = lib.mkForce false;

    # QEMU guest agent for hypervisor integration (shutdown, freeze, etc.)
    services.qemuGuest.enable = true;

    # QXL video driver for better VM performance
    services.xserver.videoDrivers = [ "qxl" ];

    # VirtIO drivers
    boot.initrd.kernelModules = [ "virtio_gpu" ];

    # Disable systemd-ssh-generator VSOCK auto-binding (unless VSOCK device configured)
    boot.kernelParams = [ "systemd.ssh_auto=no" ];

    # Basic graphics
    hardware.graphics = {
      enable = true;
    };

    # No power management needed in VM
    services.tlp.enable = lib.mkForce false;
    services.power-profiles-daemon.enable = false;

    # Filesystem trim support for thin-provisioned disks
    services.fstrim.enable = true;
  };
}

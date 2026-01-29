{ config, lib, ... }:

{
  flake.modules.nixos.hardware-proxmox-vm = { config, lib, pkgs, modulesPath, ... }: {
    imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

    # QEMU guest agent for Proxmox integration (shutdown, freeze, IP reporting)
    services.qemuGuest.enable = true;

    # Virtio drivers for performance
    boot.initrd.availableKernelModules = [
      "virtio_pci" "virtio_scsi" "virtio_blk" "virtio_net"
      "ahci" "sd_mod" "sr_mod"
    ];

    # Console configuration: both VGA (tty1) and serial for Proxmox
    # Disable systemd-ssh-generator VSOCK auto-binding (Proxmox doesn't provide VSOCK)
    boot.kernelParams = [
      "console=tty1"
      "console=ttyS0,115200"
      "systemd.ssh_auto=no"
    ];

    # No power management needed in VM
    services.tlp.enable = lib.mkForce false;
    services.power-profiles-daemon.enable = false;

    # Filesystem trim support for thin-provisioned disks
    services.fstrim.enable = true;
  };
}

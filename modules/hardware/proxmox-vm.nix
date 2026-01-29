{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  # QEMU guest agent for Proxmox integration (shutdown, freeze, IP reporting)
  services.qemuGuest.enable = true;

  # Virtio drivers for performance
  boot.initrd.availableKernelModules = [
    "virtio_pci" "virtio_scsi" "virtio_blk" "virtio_net"
    "ahci" "sd_mod" "sr_mod"
  ];

  # Console for Proxmox serial access
  boot.kernelParams = [ "console=ttyS0,115200" ];

  # Blacklist vsock modules - Proxmox doesn't provide VSOCK device
  # Prevents "Failed to query local AF_VSOCK CID" errors
  boot.blacklistedKernelModules = [ "vsock" "vmw_vsock_virtio_transport" "vmw_vsock_vmci_transport" ];

  # No power management needed in VM
  services.tlp.enable = lib.mkForce false;
  services.power-profiles-daemon.enable = false;

  # Filesystem trim support for thin-provisioned disks
  services.fstrim.enable = true;
}

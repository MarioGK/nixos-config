{ config, lib, pkgs, ... }:

{
  # Libvirt daemon for VM management
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;  # TPM emulation
      ovmf = {
        enable = true;  # UEFI support
        packages = [ pkgs.OVMFFull.fd ];
      };
    };
  };

  # Spice USB redirection
  virtualisation.spiceUSBRedirection.enable = true;

  # Virt-manager GUI
  programs.virt-manager.enable = true;

  # Add user to libvirtd group
  users.users.mariogk.extraGroups = [ "libvirtd" ];

  # Virtualization packages
  environment.systemPackages = with pkgs; [
    virt-manager       # GUI for managing VMs
    virt-viewer        # Remote VM viewer
    spice-gtk          # Spice client
    win-virtio         # VirtIO drivers for Windows guests
    swtpm              # TPM emulator
  ];

  # Enable dconf for virt-manager settings persistence
  programs.dconf.enable = true;
}

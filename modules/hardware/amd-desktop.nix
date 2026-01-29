{ config, lib, ... }:

{
  flake.modules.nixos.hardware-amd-desktop = { config, lib, pkgs, ... }: {
    # AMD microcode updates
    hardware.cpu.amd.updateMicrocode = true;

    # AMD IOMMU kernel parameters
    boot.kernelParams = [ "amd_iommu=on" "iommu=pt" ];

    # Kernel modules for AMD
    boot.initrd.kernelModules = [ "amdgpu" ];
    boot.kernelModules = [ "kvm-amd" "ixgbe" ];  # ixgbe for 10GbE NIC

    # Filesystem support
    boot.supportedFilesystems = [ "ntfs" ];

    # AMD GPU configuration (RX 7700 - RDNA 3)
    # RADV (Mesa Vulkan) is now the default and recommended driver
    hardware.graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        rocmPackages.clr    # OpenCL runtime
        libva               # VAAPI
      ];
    };

    # LACT - Linux AMDGPU Controller daemon
    # Provides GPU monitoring and control (fan curves, power limits, etc.)
    services.lact = {
      enable = true;
    };

    # OpenRGB for RGB LED control
    services.hardware.openrgb = {
      enable = true;
      motherboard = "amd";
    };

    # Logitech Unifying Receiver
    hardware.logitech.wireless = {
      enable = true;
      enableGraphical = true;  # Solaar GUI
    };

    # Diagnostic and hardware tools
    environment.systemPackages = with pkgs; [
      radeontop      # AMD GPU monitoring
      lact           # GPU control GUI
      vulkan-tools   # vulkaninfo
      libva-utils    # vainfo
      clinfo         # OpenCL info
      openrgb        # RGB LED control
      solaar         # Logitech device manager
      v4l-utils      # Video4Linux utilities
      exfatprogs     # exFAT filesystem tools
      ntfs3g         # NTFS filesystem support
    ];
  };
}

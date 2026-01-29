{ config, lib, pkgs, ... }:

{
  # AMD microcode updates
  hardware.cpu.amd.updateMicrocode = true;

  # AMD IOMMU kernel parameters
  boot.kernelParams = [ "amd_iommu=on" "iommu=pt" ];

  # Kernel modules for AMD
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];

  # AMD GPU configuration (RX 7700 - RDNA 3)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      amdvlk              # AMD Vulkan driver
      rocmPackages.clr    # OpenCL runtime
      libva               # VAAPI
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      amdvlk
    ];
  };

  # Environment variables for AMD GPU
  environment.variables = {
    # Use RADV by default (Mesa Vulkan, generally better for gaming)
    # Set to amdvlk if needed: AMD_VULKAN_ICD=AMDVLK
    AMD_VULKAN_ICD = "RADV";
  };

  # LACT - Linux AMDGPU Controller daemon
  # Provides GPU monitoring and control (fan curves, power limits, etc.)
  services.lact = {
    enable = true;
  };

  # Diagnostic tools
  environment.systemPackages = with pkgs; [
    radeontop      # AMD GPU monitoring
    lact           # GPU control GUI
    vulkan-tools   # vulkaninfo
    libva-utils    # vainfo
    clinfo         # OpenCL info
  ];
}

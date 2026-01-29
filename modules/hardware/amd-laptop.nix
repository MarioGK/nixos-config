# AMD Ryzen laptop hardware configuration
# Suitable for AMD APUs with integrated Radeon graphics
{ config, lib, pkgs, ... }:

{
  # AMD microcode updates
  hardware.cpu.amd.updateMicrocode = true;

  # AMD IOMMU kernel parameters
  boot.kernelParams = [ "amd_iommu=on" "iommu=pt" ];

  # Kernel modules for AMD
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];

  # AMD GPU configuration (integrated Radeon graphics)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      amdvlk   # AMD Vulkan driver
      libva    # VAAPI for video acceleration
    ];
  };

  # Environment variables for AMD GPU
  environment.variables = {
    # Use RADV by default (Mesa Vulkan, generally better)
    AMD_VULKAN_ICD = "RADV";
  };

  # TLP for laptop power management
  services.tlp = {
    enable = true;
    settings = {
      # CPU settings
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      # Platform profile
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "balanced";

      # WiFi power saving
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      # USB autosuspend
      USB_AUTOSUSPEND = 1;

      # PCIe power management
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";

      # Battery charge thresholds (ThinkPad supported)
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Disable power-profiles-daemon (conflicts with TLP)
  services.power-profiles-daemon.enable = false;

  # Diagnostic tools
  environment.systemPackages = with pkgs; [
    radeontop     # AMD GPU monitoring
    vulkan-tools  # vulkaninfo
    libva-utils   # vainfo
    powertop      # Power analysis
  ];
}

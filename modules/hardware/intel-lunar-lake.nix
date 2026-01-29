{ config, lib, pkgs, ... }:

{
  # Intel microcode updates
  hardware.cpu.intel.updateMicrocode = true;

  # Intel GPU configuration (Arc Graphics 130V/140V)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      intel-media-driver    # VAAPI driver for video acceleration
      intel-compute-runtime # OpenCL support
      vpl-gpu-rt           # Intel Video Processing Library
      libvdpau-va-gl       # VDPAU backend for VAAPI
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
    ];
  };

  # Environment variables for Intel GPU
  environment.variables = {
    # Force VAAPI driver
    LIBVA_DRIVER_NAME = "iHD";
    # Vulkan ICD
    VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
  };

  # Power management for Intel
  services.thermald.enable = true;

  # Enable TLP for battery optimization
  services.tlp = {
    enable = true;
    settings = {
      # CPU settings
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      # Intel P-state settings
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 80;

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

      # Battery charge thresholds (if supported)
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Disable power-profiles-daemon (conflicts with TLP)
  services.power-profiles-daemon.enable = false;

  # Intel NPU support (nascent, kernel 6.11+)
  # The NPU is exposed as /dev/accel* when supported
  boot.kernelModules = [ "intel_vpu" ];

  # Diagnostic tools
  environment.systemPackages = with pkgs; [
    intel-gpu-tools     # intel_gpu_top
    libva-utils         # vainfo
    vulkan-tools        # vulkaninfo
    powertop            # Power analysis
  ];
}

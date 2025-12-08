{ config, pkgs, ... }:

{
  profiles = {
    development = true;
    multimedia = true;
    laptop-specific = true;
    gaming = true;
  };

  # Laptop-specific packages
  environment.systemPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
    intel-gpu-tools
    sof-firmware
    alsa-ucm-conf
    nvtopPackages.intel
  ];

  # Firmware for audio
  hardware.firmware = [
    pkgs.sof-firmware
    pkgs.alsa-firmware
  ];

  # Power management
  powerManagement.enable = true;

  # Intel graphics configuration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs; [
      vaapiIntel
      libvdpau-va-gl
    ];
  };

  # KWin HDR configuration
  environment.etc."xdg/kwinrc".text = ''
    [Compositing]
    EnableHDR=true
    MaxFPS=120
  '';
}
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ../../modules/base.nix
    ../../hardware/laptop.nix
    ../../modules/tlp.nix
    ../../modules/update-on-shutdown.nix
    inputs.nixos-hardware.nixosModules.lenovo-yoga-7-14ILL10
  ];

  networking.hostName = "mario-laptop";

  powerManagement.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
    # `intel-media-driver` is already included in the default set of
    # 32-bit graphics drivers. Including it again leads to file
    # collisions when building the `graphics-drivers-32bit` package.
    extraPackages32 = with pkgs; [
      vaapiIntel
      libvdpau-va-gl
    ];

  };

  environment.etc."xdg/kwinrc".text = ''
    [Compositing]
    EnableHDR=true
    MaxFPS=120
  '';

  # Intel specific performance tools for this notebook
  environment.systemPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
    intel-gpu-tools
    sof-firmware
    alsa-ucm-conf
    nvtopPackages.intel
  ];

  hardware.firmware = [
    pkgs.sof-firmware
    pkgs.alsa-firmware
  ];
}

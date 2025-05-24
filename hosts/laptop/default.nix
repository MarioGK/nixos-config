{
  config,
  lib,
  pkgs,
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
    extraPackages32 = with pkgs; [
      intel-media-driver
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
  ];

  hardware.firmware = [
    pkgs.sof-firmware
    pkgs.alsa-firmware
  ];
}

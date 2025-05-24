{ config, pkgs, ... }:
{
  imports = [
    ../../modules/base.nix
    ../../hardware/laptop.nix
    ../../modules/tlp.nix
    ../../modules/update-on-shutdown.nix
  ];

  networking.hostName = "mario-laptop";

  powerManagement.enable = true;

  # Force display settings for the laptop
  environment.sessionVariables = {
    #QT_SCALE_FACTOR = "1.6";
    #GDK_SCALE = "1.6";
  };

  hardware.intelgpu = {
    driver = lib.mkIf (lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.8") "xe";
    vaapiDriver = "intel-media-driver";
  };

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
  ];

  hardware.firmware = [ unstablePkgs.sof-firmware pkgs.alsa-firmware ];
}

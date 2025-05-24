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
  ];

  networking.hostName = "mario-laptop";

  powerManagement.enable = true;

  services.pipewire = {
    jack.enable = true;
    wireplumber.enable = true;
  };

  environment = {
    sessionVariables.ALSA_CONFIG_UCM2 = "${alsa-ucm-conf-latest}/share/alsa/ucm2";
  };

  # Enable the Intel GPU driver without relying on X11
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
    alsa-ucm-conf-latest
  ];

  hardware.firmware = [
    pkgs.sof-firmware
    pkgs.alsa-firmware
  ];
}

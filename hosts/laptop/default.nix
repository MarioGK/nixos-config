{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Custom package for alsa-ucm-conf 1.2.14
  # Can be removed when 1.2.14 gets included in nixpkgs
  alsa-ucm-conf-latest = pkgs.alsa-ucm-conf.overrideAttrs (oldAttrs: {
    version = "1.2.14";
    src = pkgs.fetchurl {
      url = "mirror://alsa/lib/alsa-ucm-conf-1.2.14.tar.bz2";
      hash = "sha256-MumAn1ktkrl4qhAy41KTwzuNDx7Edfk3Aiw+6aMGnCE=";
    };
    postPatch = ''
      sed -i 's#/sbin/modprobe#${pkgs.kmod}/bin/modprobe#' ucm2/HDA/HDA.conf 2>/dev/null || true
      sed -i 's#/usr/sbin/modprobe#${pkgs.kmod}/bin/modprobe#' ucm2/HDA/HDA.conf 2>/dev/null || true
    '';
  });
in
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

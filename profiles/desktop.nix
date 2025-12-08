{ config, pkgs, ... }:

{
  profiles = {
    development = true;
    multimedia = true;
    desktop-specific = true;
    gaming = true;
  };

  # Desktop-specific packages
  environment.systemPackages = with pkgs; [
    amdvlk
    radeontop
    lact
  ];

  # AMD graphics configuration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      amdvlk
    ];
  };
}
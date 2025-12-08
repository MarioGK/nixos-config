{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  # Hardware configuration for Laptop PlanA:
  # Lenovo ThinkPad E14 Gen 6 — Ryzen 7 7735HS with Radeon 680M iGPU
  # This file contains general hardware hints (drivers, microcode) and is
  # intentionally conservative: avoid machine-specific disk layout entries.

  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      mesa
      amdvlk
      radeontop
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      amdvlk
    ];
  };

  # Use AMD microcode updates when redistributable firmware is allowed
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Provide a reasonable swapfile fallback for laptops that don't use
  # a dedicated swap partition in the installer-generated hardware files.
  swapDevices = [
    {
      device = "/swapfile";
      size = 48 * 1024;
    }
  ];
}

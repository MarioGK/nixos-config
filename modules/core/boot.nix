{ config, lib, pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };

    # Kernel configuration
    kernelPackages = pkgs.linuxPackages_latest;

    # Required for TPM2 auto-unlock
    initrd.systemd.enable = true;

    # Common kernel parameters
    kernelParams = [
      "quiet"
      "splash"
    ];

    # Plymouth boot splash
    plymouth = {
      enable = true;
      theme = "breeze";
    };

    # LUKS configuration - UUIDs to be filled from hardware-configuration.nix
    # TPM2 auto-unlock is configured via crypttabExtraOpts
    # After first boot, enroll TPM with:
    # sudo systemd-cryptenroll --tpm2-device=auto /dev/nvme0n1p2
  };

  # Enable firmware updates
  services.fwupd.enable = true;

  # Allow unfree firmware
  hardware.enableRedistributableFirmware = true;

  # zram swap (compressed in-memory swap)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };
}

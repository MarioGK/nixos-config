{ config, lib, pkgs, ... }:

{
  # Bluetooth support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;  # Enable experimental features
        FastConnectable = true;
      };
    };
  };

  # Blueman applet (optional, KDE has built-in)
  # services.blueman.enable = true;

  # Bluetooth audio codecs
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
  ];
}

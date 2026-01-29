{ config, lib, ... }:

{
  flake.modules.nixos.base-audio = { config, lib, pkgs, ... }: {
    # SOF firmware for Intel Lunar Lake audio
    hardware.firmware = with pkgs; [
      sof-firmware
    ];

    # PipeWire for audio
    services.pipewire = {
      enable = true;

      # Enable all audio systems
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      # WirePlumber session manager
      wireplumber.enable = true;
    };

    # Disable PulseAudio (using PipeWire)
    services.pulseaudio.enable = false;

    # Audio packages
    environment.systemPackages = with pkgs; [
      pavucontrol       # PulseAudio volume control
      pwvucontrol       # PipeWire volume control
      helvum            # PipeWire patchbay
      qpwgraph          # PipeWire graph
    ];

    # Environment for better audio
    environment.variables = {
      # PipeWire is the default, but be explicit
      SDL_AUDIODRIVER = "pipewire";
    };
  };
}

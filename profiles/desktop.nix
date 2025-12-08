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

  # KWin HDR configuration for desktop
  environment.etc."xdg/kwinrc".text = ''
    [Compositing]
    EnableHDR=true
    MaxFPS=144
  '';

  # Desktop-specific Flatpak packages
  system.activationScripts.desktop-flatpak.text = ''
    ${pkgs.flatpak}/bin/flatpak install --noninteractive flathub net.mkiol.SpeechNote.Addon.amd
  '';

  # Ensure desktop flatpak script runs after base setup
  systemd.services.desktop-flatpak = {
    wantedBy = [ "multi-user.target" ];
    after = [ "flatpak-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.flatpak}/bin/flatpak install --noninteractive flathub net.mkiol.SpeechNote.Addon.amd'";
    };
  };
}
{ config, lib, pkgs, ... }:

{
  # Enable Flatpak
  services.flatpak.enable = true;

  # Flatpak needs XDG portal
  xdg.portal.enable = true;

  # Add Flathub repository on activation
  system.activationScripts.flatpak-repo = ''
    ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  '';

  # Flatpak CLI
  environment.systemPackages = with pkgs; [
    flatpak
  ];

  # Recommended Flatpak apps to install manually:
  # flatpak install flathub com.github.wwmm.easyeffects
  # flatpak install flathub io.missioncenter.MissionCenter
  # flatpak install flathub net.mkiol.SpeechNote
  # flatpak install flathub io.kinvolk.Headlamp  # Kubernetes GUI
}

{ config, lib, pkgs, ... }:

{
  # KDE Plasma 6
  services.desktopManager.plasma6.enable = true;

  # SDDM display manager with Wayland
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    defaultSession = "plasma";
  };

  # XDG portal for Wayland
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-kde
    ];
  };

  # Environment variables for Wayland
  environment.sessionVariables = {
    # Force Wayland for various apps
    NIXOS_OZONE_WL = "1";  # Electron apps
    MOZ_ENABLE_WAYLAND = "1";  # Firefox
    QT_QPA_PLATFORM = "wayland;xcb";  # Qt fallback to X11
    SDL_VIDEODRIVER = "wayland";  # SDL2

    # KDE-specific
    QT_QPA_PLATFORMTHEME = "kde";
  };

  # KDE applications
  environment.systemPackages = with pkgs; [
    # Core KDE apps
    kdePackages.ark           # Archive manager
    kdePackages.dolphin       # File manager
    kdePackages.kate          # Text editor
    kdePackages.kcalc         # Calculator
    kdePackages.konsole       # Terminal
    kdePackages.spectacle     # Screenshots
    kdePackages.gwenview      # Image viewer
    kdePackages.okular        # Document viewer
    kdePackages.filelight     # Disk usage
    kdePackages.partitionmanager  # Disk partitions
    kdePackages.kdeconnect-kde    # Phone integration

    # System tools
    kdePackages.plasma-systemmonitor
    kdePackages.ksystemlog
    kdePackages.kwalletmanager

    # Theming
    kdePackages.breeze-icons

    # Wayland utilities
    wl-clipboard
    xwaylandvideobridge  # For screen sharing
  ];

  # D-Bus for KDE Connect
  programs.kdeconnect.enable = true;

  # Enable location services
  services.geoclue2.enable = true;

  # GVFS for file manager features
  services.gvfs.enable = true;

  # Thumbnail generation
  services.tumbler.enable = true;
}

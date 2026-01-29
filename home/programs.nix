{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Browsers
    zen-browser  # From overlay

    # Communication
    telegram-desktop

    # Media
    youtube-music
    vlc
    mpv

    # Productivity
    obsidian
    bitwarden

    # System monitoring
    htop
    btop

    # File management
    p7zip
    unzip
    unrar

    # Networking
    wget
    aria2

    # Screenshots and recording
    kooha  # Screen recorder

    # Utilities
    neofetch
    fastfetch
    tree
    tldr
  ];

  # Firefox as backup browser
  programs.firefox = {
    enable = true;

    profiles.default = {
      settings = {
        # Privacy
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "browser.send_pings" = false;

        # Performance
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;

        # Wayland
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };
  };

  # MPV configuration
  programs.mpv = {
    enable = true;

    config = {
      profile = "gpu-hq";
      vo = "gpu-next";
      gpu-api = "vulkan";
      hwdec = "auto-safe";

      # Audio
      audio-pitch-correction = true;
      volume-max = 150;

      # Subtitles
      sub-auto = "fuzzy";
      sub-font-size = 40;

      # Screenshots
      screenshot-format = "png";
      screenshot-directory = "~/Pictures/Screenshots";
    };
  };

  # Btop configuration
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "dracula";
      theme_background = false;
      vim_keys = true;
    };
  };
}

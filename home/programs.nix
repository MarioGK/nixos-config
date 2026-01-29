{ config, lib, pkgs, ... }:

{
  # Autostart Bitwarden minimized to tray
  xdg.configFile."autostart/bitwarden.desktop".text = ''
    [Desktop Entry]
    Name=Bitwarden
    Exec=bitwarden --hidden
    Terminal=false
    Type=Application
    Icon=bitwarden
    StartupWMClass=Bitwarden
    Comment=Password Manager
    Categories=Utility;Security;
  '';

  home.packages = with pkgs; [
    # Browsers
    zen-browser      # From overlay
    helium-browser   # From overlay - privacy-focused Chromium

    # Communication
    telegram-desktop
    legcord      # Discord client
    thunderbird  # Email client

    # Media
    youtube-music
    vlc
    mpv

    # Productivity
    obsidian

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

  # Bitwarden CLI (rbw)
  programs.rbw = {
    enable = true;
    settings = {
      email = "mariogk01@gmail.com";
      base_url = "https://vw.mariogk.com";
      lock_timeout = 0;  # Never lock
      pinentry = pkgs.pinentry-qt;
    };
  };

  # rbw SSH agent - set socket for SSH to use
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/rbw/ssh-agent-socket";
  };

  # Start rbw agent and unlock on login
  systemd.user.services.rbw-agent = {
    Unit = {
      Description = "rbw agent for Bitwarden";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.rbw}/bin/rbw unlock";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Auto-sync rbw periodically
  systemd.user.services.rbw-sync = {
    Unit = {
      Description = "Sync rbw vault";
      After = [ "rbw-agent.service" "network-online.target" ];
      Requires = [ "rbw-agent.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.rbw}/bin/rbw sync";
    };
  };

  systemd.user.timers.rbw-sync = {
    Unit.Description = "Periodic rbw sync";
    Timer = {
      OnBootSec = "2min";
      OnUnitActiveSec = "15min";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}

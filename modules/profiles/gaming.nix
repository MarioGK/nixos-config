{ config, lib, pkgs, ... }:

{
  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # Gamemode - system optimizations for gaming
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };

  # Gaming packages
  environment.systemPackages = with pkgs; [
    mangohud       # Vulkan/OpenGL overlay for FPS, CPU/GPU stats
    protonup-qt    # GUI for managing Proton-GE versions
    gamescope      # SteamOS session compositor
    libnotify      # For gamemode notifications
  ];

  # Security settings for gaming
  security.rtkit.enable = true;

  # Increase memlock limit for games that need it
  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "memlock";
      type = "soft";
      value = "unlimited";
    }
    {
      domain = "@users";
      item = "memlock";
      type = "hard";
      value = "unlimited";
    }
  ];
}

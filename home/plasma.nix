{ config, lib, pkgs, ... }:

{
  # plasma-manager for declarative KDE configuration
  programs.plasma = {
    enable = true;

    # Workspace settings
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      colorScheme = "BreezeDark";
      theme = "breeze-dark";
      iconTheme = "breeze-dark";
      cursor = {
        theme = "Breeze";
        size = 24;
      };
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Next/contents/images_dark/3840x2160.png";
    };

    # Panel configuration
    panels = [
      {
        location = "bottom";
        height = 44;
        floating = true;

        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General = {
                launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "applications:org.kde.konsole.desktop"
                  "applications:code.desktop"
                  "applications:zen.desktop"
                ];
              };
            };
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
    ];

    # KWin window manager
    kwin = {
      titlebarButtons = {
        left = [ "on-all-desktops" ];
        right = [ "minimize" "maximize" "close" ];
      };

      effects = {
        shakeCursor.enable = true;
        desktopSwitching.animation = "slide";
      };

      virtualDesktops = {
        rows = 1;
        number = 4;
        names = [ "Main" "Work" "Code" "Media" ];
      };
    };

    # Hotkeys
    hotkeys.commands = {
      "launch-konsole" = {
        name = "Launch Konsole";
        key = "Meta+Return";
        command = "konsole";
      };
      "launch-dolphin" = {
        name = "Launch Dolphin";
        key = "Meta+E";
        command = "dolphin";
      };
    };

    # Shortcuts
    shortcuts = {
      kwin = {
        "Switch to Desktop 1" = "Meta+1";
        "Switch to Desktop 2" = "Meta+2";
        "Switch to Desktop 3" = "Meta+3";
        "Switch to Desktop 4" = "Meta+4";
        "Window to Desktop 1" = "Meta+!";
        "Window to Desktop 2" = "Meta+@";
        "Window to Desktop 3" = "Meta+#";
        "Window to Desktop 4" = "Meta+$";
        "Window Maximize" = "Meta+Up";
        "Window Minimize" = "Meta+Down";
        "Window Quick Tile Left" = "Meta+Left";
        "Window Quick Tile Right" = "Meta+Right";
        "Window Close" = "Meta+Q";
        "Overview" = "Meta+Tab";
      };

      plasmashell = {
        "show-on-mouse-pos" = "Meta+V";  # Clipboard
      };

      "org.kde.spectacle.desktop" = {
        "RectangularRegionScreenShot" = "Meta+Shift+S";
        "FullScreenScreenShot" = "Print";
        "ActiveWindowScreenShot" = "Meta+Print";
      };
    };

    # Power management
    powerdevil = {
      AC = {
        autoSuspend.action = "nothing";
        powerButtonAction = "showLogoutScreen";
        dimDisplay.enable = true;
        dimDisplay.idleTimeout = 300;
        turnOffDisplay.idleTimeout = 600;
      };
      battery = {
        autoSuspend.action = "sleep";
        autoSuspend.idleTimeout = 900;
        powerButtonAction = "sleep";
        dimDisplay.enable = true;
        dimDisplay.idleTimeout = 120;
        turnOffDisplay.idleTimeout = 300;
      };
      lowBattery = {
        autoSuspend.action = "sleep";
        autoSuspend.idleTimeout = 120;
        powerButtonAction = "sleep";
      };
    };

    # Konsole profile
    configFile = {
      # KDE settings
      kdeglobals = {
        General = {
          AccentColor = "61,174,233";
        };
        KDE = {
          SingleClick = false;  # Double-click to open
        };
      };

      # Dolphin settings
      dolphinrc = {
        General = {
          ShowHiddenFiles = true;
          BrowseThroughArchives = true;
        };
        DetailsMode = {
          PreviewSize = 32;
        };
      };

      # KWin settings
      kwinrc = {
        Compositing = {
          GLCore = true;
          OpenGLIsUnsafe = false;
        };
        Wayland = {
          InputMethod = "";
          VirtualKeyboardEnabled = false;
        };
        Xwayland = {
          Scale = 1;
        };
      };
    };
  };
}

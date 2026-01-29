{ config, lib, pkgs, ... }:

{
  # Konsole blur profile
  xdg.dataFile."konsole/Blur.profile".text = ''
    [Appearance]
    ColorScheme=BlurDark
    Font=JetBrainsMono Nerd Font,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
    UseFontLineChararacters=true

    [Cursor Options]
    CursorShape=1
    UseCustomCursorColor=false

    [General]
    Command=/run/current-system/sw/bin/fish
    Name=Blur
    Parent=FALLBACK/
    TerminalCenter=true
    TerminalMargin=10

    [Scrolling]
    HistoryMode=2
    ScrollBarPosition=2

    [Terminal Features]
    BlinkingCursorEnabled=true
    UrlHintsModifiers=0
  '';

  # Konsole blur color scheme (dark with transparency)
  xdg.dataFile."konsole/BlurDark.colorscheme".text = ''
    [Background]
    Color=23,23,23

    [BackgroundFaint]
    Color=23,23,23

    [BackgroundIntense]
    Color=23,23,23

    [Color0]
    Color=35,38,39

    [Color0Faint]
    Color=49,54,59

    [Color0Intense]
    Color=127,140,141

    [Color1]
    Color=237,21,21

    [Color1Faint]
    Color=120,50,40

    [Color1Intense]
    Color=192,57,43

    [Color2]
    Color=17,209,22

    [Color2Faint]
    Color=23,162,98

    [Color2Intense]
    Color=28,220,154

    [Color3]
    Color=246,116,0

    [Color3Faint]
    Color=182,86,25

    [Color3Intense]
    Color=253,188,75

    [Color4]
    Color=29,153,243

    [Color4Faint]
    Color=27,102,143

    [Color4Intense]
    Color=61,174,233

    [Color5]
    Color=155,89,182

    [Color5Faint]
    Color=97,74,115

    [Color5Intense]
    Color=142,68,173

    [Color6]
    Color=26,188,156

    [Color6Faint]
    Color=24,108,96

    [Color6Intense]
    Color=22,160,133

    [Color7]
    Color=252,252,252

    [Color7Faint]
    Color=99,104,109

    [Color7Intense]
    Color=255,255,255

    [Foreground]
    Color=252,252,252

    [ForegroundFaint]
    Color=239,240,241

    [ForegroundIntense]
    Color=255,255,255

    [General]
    Anchor=0.5,0.5
    Blur=true
    ColorRandomization=false
    Description=Blur Dark
    FillStyle=Tile
    Opacity=0.7
    Wallpaper=
    WallpaperFlipType=NoFlip
    WallpaperOpacity=1
  '';

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
        blur.enable = true;
        translucency.enable = true;
      };

      # Hide window decoration when maximized
      borderlessMaximizedWindows = true;

      virtualDesktops = {
        rows = 2;
        number = 4;
        names = [ "Main" "Code" "Media" "Work" ];
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
      # Keyboard settings
      kcminputrc = {
        Keyboard = {
          NumLock = 0;  # 0 = on, 1 = off, 2 = unchanged
        };
      };

      # KDE settings
      kdeglobals = {
        General = {
          AccentColor = "61,174,233";
        };
        KDE = {
          SingleClick = false;  # Double-click to open
          AnimationDurationFactor = "0.5";  # Faster animations (1 = normal, 0 = instant)
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
        # Hot corners - upper right opens Overview
        ElectricBorders = {
          TopRight = "Overview";
        };
        # Blur settings
        "Effect-blur" = {
          BlurStrength = 10;
          NoiseStrength = 0;
        };
        # Translucency settings
        "Effect-translucency" = {
          Inactive = 90;
          MoveResize = 80;
        };
      };

      # KRunner configuration (top center)
      krunnerrc = {
        General = {
          FreeFloating = true;
        };
        Plugins = {
          baloosearchEnabled = true;
          bookmarksEnabled = true;
          calculatorEnabled = true;
          desktopsessionsEnabled = true;
          kaboratory = true;
          kwinEnabled = true;
          locationsEnabled = true;
          "plasma-runnner-PowerDevilEnabled" = true;
          recentdocumentsEnabled = true;
          servicesEnabled = true;
          shellEnabled = true;
          webshortcutsEnabled = true;
          windowsEnabled = true;
        };
      };

      # Clipboard (Klipper) - maximum history size
      klipperrc = {
        General = {
          KeepClipboardContents = true;
          MaxClipItems = 1000;
          SyncClipboards = true;
        };
      };

      # Session restore
      ksmserverrc = {
        General = {
          loginMode = "restorePreviousLogout";
        };
      };

      # Konsole settings
      konsolerc = {
        "Desktop Entry" = {
          DefaultProfile = "Blur.profile";
        };
        TabBar = {
          TabBarPosition = "Top";
          TabBarVisibility = "ShowTabBarWhenNeeded";
        };
      };

      # Baloo file indexing
      baloofilerc = {
        "Basic Settings" = {
          Indexing-Enabled = true;
        };
        General = {
          "only basic indexing" = false;
        };
      };

      # Discover software updates (Automatic, Daily, After Rebooting)
      discoverrc = {
        Software = {
          UseOfflineUpdates = true;  # Apply updates after reboot
        };
      };

      # Plasma Discover notifier (automatic updates)
      PlasmaDiscoverUpdates = {
        Global = {
          RequiredNotificationInterval = 86400;  # Daily (in seconds)
          UseUnattendedUpdates = true;  # Automatic updates
        };
      };

      # Spellcheck configuration (Sonnet/Hunspell)
      sonnetrc = {
        General = {
          autodetectLanguage = true;
          checkerEnabledByDefault = true;
        };
        Speller = {
          defaultLanguage = "en_US";
          preferredLanguages = "en_US,pt_BR";
        };
      };
    };
  };
}

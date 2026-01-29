# Desktop Environment

This guide covers KDE Plasma 6 configuration, plasma-manager integration, SDDM, and Wayland setup.

## Overview

This configuration uses KDE Plasma 6 as the desktop environment with Wayland as the display protocol. Home Manager with plasma-manager provides declarative desktop configuration.

## KDE Plasma 6 Setup

### System Configuration

```nix
# modules/base.nix
{ config, lib, pkgs, ... }:
{
  # Enable KDE Plasma 6
  services.desktopManager.plasma6.enable = true;

  # Exclude default packages (optional)
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa       # Music player
    gwenview    # Image viewer
    okular      # Document viewer
  ];
}
```

### SDDM Display Manager

```nix
services.displayManager.sddm = {
  enable = true;
  wayland.enable = true;  # Use Wayland for login screen
  autoLogin = {
    enable = true;
    user = "mariogk";
  };
};
```

## plasma-manager Integration

plasma-manager provides declarative Plasma configuration through Home Manager.

### Flake Input

```nix
# flake.nix
{
  inputs = {
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };
}
```

### Home Manager Configuration

```nix
# home/mariogk.nix
{ config, pkgs, ... }:
{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  programs.plasma = {
    enable = true;

    # Workspace settings
    workspace = {
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      cursorTheme = "breeze_cursors";
      iconTheme = "breeze-dark";
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Next/contents/images/1920x1080.png";
    };
  };
}
```

## Panel Configuration

### Bottom Taskbar (Windows-like)

```nix
programs.plasma.panels = [
  {
    location = "bottom";
    height = 44;
    widgets = [
      {
        name = "org.kde.plasma.kickoff";
        config.General.icon = "nix-snowflake-white";
      }
      {
        name = "org.kde.plasma.icontasks";
        config.General = {
          launchers = [
            "applications:org.kde.dolphin.desktop"
            "applications:firefox.desktop"
            "applications:org.kde.konsole.desktop"
          ];
        };
      }
      "org.kde.plasma.marginsseparator"
      {
        name = "org.kde.plasma.systemtray";
      }
      {
        name = "org.kde.plasma.digitalclock";
        config.Appearance = {
          showDate = true;
          dateFormat = "shortDate";
        };
      }
    ];
  }
];
```

### Top Global Menu Panel

```nix
programs.plasma.panels = [
  # ... bottom panel ...
  {
    location = "top";
    height = 26;
    widgets = [
      "org.kde.plasma.appmenu"
      "org.kde.plasma.panelspacer"
      "org.kde.plasma.systemmonitor.cpu"
      "org.kde.plasma.systemmonitor.memory"
    ];
  }
];
```

## Virtual Desktops

```nix
programs.plasma.kwin.virtualDesktops = {
  rows = 1;
  number = 3;
  names = [ "Main" "Development" "Communication" ];
};
```

## Keyboard Shortcuts

```nix
programs.plasma.shortcuts = {
  # Application launchers
  "services/org.kde.konsole.desktop"."_launch" = "Meta+Alt+K";

  # Window management (vim-style)
  kwin = {
    "Window Quick Tile Left" = "Meta+H";
    "Window Quick Tile Right" = "Meta+L";
    "Window Quick Tile Top" = "Meta+K";
    "Window Quick Tile Bottom" = "Meta+J";
    "Expose" = "Meta+,";
    "ExposeAll" = "Meta+Shift+,";
  };

  # Session management
  "ksmserver"."Lock Session" = "Meta+Ctrl+Alt+L";
};
```

## KWin Settings

### Window Behavior

```nix
programs.plasma.kwin = {
  # Borderless maximized windows
  borderlessMaximizedWindows = true;

  # Compositing
  nightLight.enable = false;

  # Effects
  effects.blur.enable = true;
};
```

### KWinrc Direct Configuration

For settings not exposed by plasma-manager:

```nix
xdg.configFile."kwinrc".text = ''
  [Compositing]
  MaxFPS=120
  RefreshRate=120

  [Plugins]
  blurEnabled=true
  contrastEnabled=true

  [Windows]
  BorderlessMaximizedWindows=true

  [Xwayland]
  Scale=1
'';
```

## KDE Applications

### Recommended Packages

```nix
home.packages = with pkgs.kdePackages; [
  # File management
  dolphin
  ark
  filelight

  # Utilities
  kate
  konsole
  kcalc
  kscreen
  partitionmanager

  # System
  plasma-systemmonitor
  spectacle

  # Integration
  plasma-browser-integration
];
```

## Wayland-Specific Settings

### Environment Variables

```nix
# In NixOS configuration
environment.sessionVariables = {
  NIXOS_OZONE_WL = "1";  # Electron apps use Wayland
};
```

### XWayland for Legacy Apps

XWayland is enabled by default. For apps requiring it:

```nix
programs.plasma.kwin.xwayland.scale = 1;
```

## Theming

### Consistent Dark Theme

```nix
programs.plasma = {
  workspace = {
    theme = "breeze-dark";
    colorScheme = "BreezeDark";
    cursorTheme = "breeze_cursors";
    iconTheme = "breeze-dark";
    lookAndFeel = "org.kde.breezedark.desktop";
  };

  fonts = {
    general = {
      family = "Noto Sans";
      pointSize = 10;
    };
    fixedWidth = {
      family = "JetBrains Mono";
      pointSize = 10;
    };
  };
};
```

## Troubleshooting

### Plasma Not Starting

Check SDDM logs:
```bash
journalctl -u sddm -b
```

### plasma-manager Changes Not Applied

Plasma caches configuration. Try:
```bash
# Logout and login, or:
kquitapp5 plasmashell && kstart5 plasmashell
```

### Missing Application Icons

Rebuild icon cache:
```bash
gtk-update-icon-cache -f ~/.local/share/icons/hicolor
```

## Related Documentation

- [Home Manager](04-home-manager.md) - Home Manager integration
- [GPU Configuration](09-gpu-configuration.md) - Graphics and HDR setup
- [Best Practices](06-best-practices.md) - Wayland configuration tips

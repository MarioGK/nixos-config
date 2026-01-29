{ config, lib, ... }:

{
  flake.modules.homeManager.programs-terminals = { config, lib, pkgs, ... }: {
    # Terminal emulators for testing

    # Ghostty
    programs.ghostty = {
      enable = true;
      enableFishIntegration = true;

      settings = {
        font-family = "JetBrainsMono Nerd Font";
        font-size = 12;
        theme = "catppuccin-mocha";

        # Wayland
        window-decoration = "server";
        gtk-titlebar = false;

        # Cursor
        cursor-style = "block";
        cursor-style-blink = false;

        # Scrollback
        scrollback-limit = 10000;

        # Padding
        window-padding-x = 8;
        window-padding-y = 8;
      };
    };

    # Alacritty
    programs.alacritty = {
      enable = true;

      settings = {
        window = {
          padding = {
            x = 8;
            y = 8;
          };
          decorations = "full";
          opacity = 0.95;
        };

        font = {
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "Regular";
          };
          bold = {
            family = "JetBrainsMono Nerd Font";
            style = "Bold";
          };
          italic = {
            family = "JetBrainsMono Nerd Font";
            style = "Italic";
          };
          size = 12.0;
        };

        scrolling = {
          history = 10000;
        };

        selection = {
          save_to_clipboard = true;
        };
      };
    };

    # Kitty
    programs.kitty = {
      enable = true;

      font = {
        name = "JetBrainsMono Nerd Font";
        size = 12;
      };

      settings = {
        # Appearance
        window_padding_width = 8;
        hide_window_decorations = "no";
        background_opacity = "0.95";

        # Cursor
        cursor_shape = "block";
        cursor_blink_interval = 0;

        # Scrollback
        scrollback_lines = 10000;

        # Bell
        enable_audio_bell = false;

        # URLs
        url_style = "curly";
        open_url_with = "default";

        # Tab bar
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
      };

      themeFile = "Catppuccin-Mocha";
    };

    # Konsole is installed system-wide as part of KDE
    # Configuration is managed by plasma-manager
  };
}

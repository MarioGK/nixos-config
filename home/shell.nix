{ config, lib, pkgs, ... }:

{
  # Fish shell
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Disable greeting
      set fish_greeting

      # Set cursor styles for vi mode
      set fish_cursor_default block
      set fish_cursor_insert line
      set fish_cursor_replace_one underscore

      # Better history search
      bind \cr history-pager

      # SOPS with Bitwarden integration
      function sops-edit
        set -l key (rbw get "SOPS Age Key" 2>/dev/null)
        if test -z "$key"
          echo "Error: Could not fetch SOPS Age Key from Bitwarden"
          echo "Make sure rbw is unlocked: rbw unlock"
          return 1
        end
        SOPS_AGE_KEY="$key" sops $argv
      end

      # NixOS rebuild with automatic hostname detection
      function rebuild
        set -l config_dir "/etc/nixos-config"
        set -l host (cat /etc/hostname)

        echo "Pulling latest changes..."
        git -C "$config_dir" pull

        echo "Rebuilding NixOS for $host..."
        sudo nixos-rebuild switch --flake "$config_dir#$host"
      end

      # NixOS rebuild boot (applies on next reboot)
      function rebuild-boot
        set -l config_dir "/etc/nixos-config"
        set -l host (cat /etc/hostname)

        echo "Pulling latest changes..."
        git -C "$config_dir" pull

        echo "Building NixOS for $host (will apply on next boot)..."
        sudo nixos-rebuild boot --flake "$config_dir#$host"
      end

      # Update flake inputs
      function update
        set -l config_dir "/etc/nixos-config"
        echo "Updating flake inputs..."
        sudo nix flake update --flake "$config_dir"
      end

      # Trust .NET dev certificates for browsers
      function dotnet-trust-cert
        set -l cert_dir "$HOME/.aspnet/https"
        set -l cert_file "$cert_dir/aspnetcore-dev.crt"

        # Generate and export the dev certificate
        echo "Generating .NET dev certificate..."
        dotnet dev-certs https --clean 2>/dev/null
        dotnet dev-certs https --trust 2>/dev/null
        mkdir -p "$cert_dir"
        dotnet dev-certs https --format PEM -ep "$cert_file" --no-password

        if not test -f "$cert_file"
          echo "Error: Failed to export certificate"
          return 1
        end

        echo "Certificate exported to $cert_file"

        # Trust for Chrome/Chromium-based browsers (Helium)
        echo "Adding to Chrome/Chromium trust store..."
        mkdir -p "$HOME/.pki/nssdb"
        certutil -d sql:"$HOME/.pki/nssdb" -D -n "ASP.NET Core Dev" 2>/dev/null
        certutil -d sql:"$HOME/.pki/nssdb" -A -t "CP,," -n "ASP.NET Core Dev" -i "$cert_file"

        # Trust for Firefox-based browsers (Zen)
        echo "Adding to Firefox trust stores..."
        for profile_dir in $HOME/.zen/*/. $HOME/.mozilla/firefox/*/.
          if test -d "$profile_dir"
            set -l profile (dirname "$profile_dir")
            if test -f "$profile/cert9.db"
              echo "  Adding to: $profile"
              certutil -d sql:"$profile" -D -n "ASP.NET Core Dev" 2>/dev/null
              certutil -d sql:"$profile" -A -t "CP,," -n "ASP.NET Core Dev" -i "$cert_file"
            end
          end
        end

        echo ""
        echo "Done! Restart your browsers for changes to take effect."
        echo "Certificate location: $cert_file"
      end
    '';

    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Modern replacements
      ls = "eza";
      ll = "eza -la";
      la = "eza -a";
      lt = "eza --tree";
      cat = "bat";

      # Git shortcuts
      g = "git";
      gs = "git status";
      gd = "git diff";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";

      # System
      reboot = "systemctl reboot";
      shutdown = "systemctl poweroff";
      poweroff = "systemctl poweroff";

      # Containers
      docker = "podman";
      docker-compose = "podman-compose";
    };

  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      add_newline = true;

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
      };

      git_status = {
        style = "bold red";
      };

      nix_shell = {
        symbol = " ";
        format = "via [$symbol$state]($style) ";
      };

      nodejs = {
        symbol = " ";
      };

      python = {
        symbol = " ";
      };

      rust = {
        symbol = " ";
      };

      golang = {
        symbol = " ";
      };

      dotnet = {
        symbol = " ";
      };
    };
  };

  # Zoxide (better cd)
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # Fzf (fuzzy finder)
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
  };

  # Bat (better cat)
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      style = "numbers,changes,header";
    };
  };

  # Eza (better ls)
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    icons = "auto";
    git = true;
  };

  # Ripgrep
  programs.ripgrep = {
    enable = true;
  };

  # Fd (better find)
  programs.fd = {
    enable = true;
  };

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}

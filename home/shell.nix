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
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos";
      update = "sudo nix flake update --flake /etc/nixos";

      # Containers
      docker = "podman";
      docker-compose = "podman-compose";
    };

    plugins = [
      # Fish plugin for better git integration
      {
        name = "fish-git-abbr";
        src = pkgs.fetchFromGitHub {
          owner = "lewisacidic";
          repo = "fish-git-abbr";
          rev = "v0.3.4";
          sha256 = "sha256-rQgnlHbEA0WXeqZf2/FNf5ofr2FTKF7VUZuuILY2C4k=";
        };
      }
    ];
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

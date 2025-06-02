{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  nixpkgs.overlays = [
    inputs.vscode-insiders.overlays.default
  ];

  home.username = "mariogk";
  home.homeDirectory = "/home/mariogk";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = [
    pkgs.kdePackages.kate
    # VSCode Insiders is now managed by the vscode-insiders.nix module
    pkgs.thunderbird
    pkgs.youtube-music
    pkgs.oh-my-posh
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.vorta
    pkgs.bun
    pkgs.jetbrains.rider # Assuming jetbrains.rider is available like this
    pkgs.legcord
    pkgs.hunspell
    pkgs.hunspellDicts.en_US
    pkgs.hunspellDicts.pt_BR
    pkgs.kdePackages.kscreen
    pkgs.kdePackages.partitionmanager
    pkgs.kdePackages.filelight
    pkgs.kdePackages.kcalc
    pkgs.kdePackages.kcharselect
    pkgs.kdePackages.kcolorchooser
    pkgs.kdePackages.kolourpaint
    pkgs.kdePackages.ksystemlog
    pkgs.kdePackages.sddm-kcm
    pkgs.kdePackages.isoimagewriter
    pkgs.haruna
    inputs.zen-browser.packages.${pkgs.system}.default
  ];

  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
    };
  };

  home = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    file = {
      "hello.txt" = {
        text = "Hello World";
      };

      ".config/powershell/Microsoft.PowerShell_profile.ps1" = {
        source = ./dotfiles/powershell/profile.ps1;
        force = true;
      };
    };
  };

  home.activation = {
    terminal-icons-install = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.powershell}/bin/pwsh -NoProfile -NonInteractive -Command "if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) { Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force }"
    '';
  };
}

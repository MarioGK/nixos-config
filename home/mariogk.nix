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

  home.username = "mariogk";
  home.homeDirectory = "/home/mariogk";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = [
    pkgs.kdePackages.kate
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

  home.file = {
    # PowerShell profile
    ".config/powershell/profile.ps1" = {
      source = ./dotfiles/profile.ps1;
      # Ensure the target directory is created if it doesn't exist.
      # This might not be strictly necessary if Home Manager handles it,
      # but it's good practice for clarity.
      # It's often handled by home.activation scripts or by home-manager itself.
      # For now, let's rely on home-manager's default behavior for parent directory creation.
    };
    # Add other specific dotfiles here in the future
  }; # <= ADDED SEMICOLON HERE

  home.activation = {
    terminal-icons-install = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.powershell}/bin/pwsh -NoProfile -NonInteractive -Command "if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) { Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force }"
    '';
  }; # <= ADDED SEMICOLON HERE
}

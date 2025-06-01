{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
    #../../modules/dotnet.nix
  ];

  home.username = "mariogk";
  home.homeDirectory = "/home/mariogk";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.packages = [
    pkgs.kdePackages.kate
    pkgs.thunderbird # thunderbird is already in pkgs
    pkgs.nano # nano is already in pkgs
    pkgs.wget # wget is already in pkgs
    pkgs.git # git is already in pkgs
    pkgs.htop # htop is already in pkgs
    pkgs.btop # btop is already in pkgs
    pkgs.youtube-music
    pkgs.zoxide
    pkgs.oh-my-posh
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.vorta
    pkgs.bun
    pkgs.jetbrains.rider # Assuming jetbrains.rider is available like this
    pkgs.legcord
    pkgs.nixfmt-rfc-style
    pkgs.hunspell # hunspell is already in pkgs
    pkgs.hunspellDicts.en_US # hunspellDicts is already in pkgs
    pkgs.hunspellDicts.pt_BR # hunspellDicts is already in pkgs
    pkgs.kdePackages.kscreen
    pkgs.kdePackages.partitionmanager
    pkgs.kdePackages.filelight
    pkgs.kdePackages.kcalc
    pkgs.kdePackages.kcharselect
    pkgs.kdePackages.kcolorchooser
    pkgs.kdePackages.kolourpaint
    pkgs.kdePackages.ksystemlog
    pkgs.kdePackages.sddm-kcm
    pkgs.kdiff3 # kdiff3 is already in pkgs
    pkgs.kdePackages.isoimagewriter
    pkgs.hardinfo2 # hardinfo2 is already in pkgs
    pkgs.haruna # haruna is already in pkgs
    inputs.zen-browser.packages.${pkgs.system}.default
    pkgs.pavucontrol # pavucontrol is already in pkgs
    pkgs.pamixer # pamixer is already in pkgs
  ];

  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
    };
  };

  home.activation = {
    powershell-profile = config.lib.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/powershell"
      ${pkgs.coreutils}/bin/install -Dm644 ../../files/powershell/profile.ps1 "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"
    '';
    terminal-icons-install = config.lib.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.powershell}/bin/pwsh -NoProfile -NonInteractive -Command "if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) { Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force }"
    '';
  };
}

{ config
, pkgs
, inputs
, ...
}:
{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  #overlays = [
  #  inputs.vscode-insiders.overlays.default
  #];

  home.username = "mariogk";
  home.homeDirectory = "/home/mariogk";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = [
    pkgs.kdePackages.kate
    pkgs.kdePackages.konsole
    pkgs.thunderbird
    pkgs.youtube-music
    pkgs.oh-my-posh
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.vorta
    pkgs.bun
    (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rider
      [
        "github-copilot"
        #"nix-idea"
        #"Key Promoter X"
        #"some.awesome"
        #"lermitage.ij.all.pack"
        #"zielu.gittoolbox"
        #"AceJump"
      ]
    )
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
    overrideConfig = true;
    workspace = {
      clickItemTo = "open";
      lookAndFeel = "org.kde.breezedark.desktop";
    };

    panels = [
      # Windows-like panel at the bottom
      {
        location = "bottom";
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
      # Global menu at the top
      {
        location = "top";
        height = 26;
        widgets = [ "org.kde.plasma.appmenu" ];
      }
    ];

    hotkeys.commands."launch-konsole" = {
      name = "Launch Konsole";
      key = "Meta+Alt+K";
      command = "konsole";
    };

    shortcuts = {
      ksmserver = {
        "Lock Session" = [
          "Screensaver"
          "Meta+Ctrl+Alt+L"
        ];
      };

      kwin = {
        "Expose" = "Meta+,";
        "Switch Window Down" = "Meta+J";
        "Switch Window Left" = "Meta+H";
        "Switch Window Right" = "Meta+L";
        "Switch Window Up" = "Meta+K";
      };
    };

    configFile = {
      #"baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
      #"kwinrc"."org.kde.kdecoration2"."ButtonsOnLeft" = "SF";
      "kwinrc"."Desktops"."Number" = {
        value = 3;
        # Forces kde to not change this value (even through the settings app).
        immutable = true;
      };
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

{
  config,
  pkgs,
  inputs,
  ...
}:

let
  dotnetCombined = (
    with pkgs.dotnetCorePackages;
    combinePackages [
      dotnet_10.sdk
      dotnet_9.sdk
    ]
  );
  aspnetCombined = (
    with pkgs.dotnetCorePackages;
    combinePackages [
      aspnetcore_10_0-bin
      aspnetcore_9_0
    ]
  );
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Use the latest Zen kernel available in nixpkgs
  boot.kernelPackages = pkgs.linuxPackages_zen;
  # Trade security for raw performance
  boot.kernelParams = [ "mitigations=off" ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.insertNameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  # Set your time zone
  time.timeZone = "Europe/Lisbon";

  # Internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  # Disable the X11 windowing system; Wayland will be used instead.
  services.xserver.enable = false;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.dconf.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    oxygen
  ];

  #qt = {
  #  enable = true;
  #  platformTheme = "gnome";
  #  style = "adwaita-dark";
  #};

  # Enable sound with pipewire.
  sound.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User account
  users.users.mariogk = {
    isNormalUser = true;
    description = "Mario Gabriell Karaziaki";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      kdePackages.kate
      thunderbird
    ];
    shell = pkgs.powershell;
  };

  # Grant user mariogk privileged actions without authentication via polkit
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.user == "mariogk") {
        return polkit.Result.YES;
      }
    });
  '';

  # Allow user mariogk to use sudo without password prompts
  security.sudo.extraRules = [
    {
      users = [ "mariogk" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Automatic login
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "mariogk";

  # Set PowerShell as the default shell for all users
  users.defaultUserShell = pkgs.powershell;
  environment.shells = with pkgs; [ powershell ];

  # Set global environment variables for .NET
  environment.sessionVariables.DOTNET_ROOT = "${dotnetCombined}/share/dotnet";

  # Install firefox
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Packages installed in system profile
  environment.systemPackages = with pkgs; [
    nano
    wget
    git
    htop
    btop
    # Media
    pkgs.youtube-music
    # Tools
    pkgs.powershell
    pkgs.zoxide
    pkgs.oh-my-posh
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.vorta
    pkgs.bun
    jetbrains.rider
    pkgs.legcord
    pkgs.nixfmt-rfc-style
    hunspell
    hunspellDicts.en_US
    hunspellDicts.pt_BR
    # KDE
    kdePackages.kscreen
    kdePackages.partitionmanager
    kdePackages.filelight
    kdePackages.kcalc
    kdePackages.kcharselect # Tool to select and copy special characters from all installed fonts
    kdePackages.kcolorchooser # A small utility to select a color
    kdePackages.kolourpaint # Easy-to-use paint program
    kdePackages.ksystemlog # KDE SystemLog Application
    kdePackages.sddm-kcm
    kdiff3
    kdePackages.isoimagewriter
    hardinfo2 # System information and benchmarks for Linux systems
    haruna
    wayland-utils
    wl-clipboard
    libva-utils
    vulkan-tools
    powertop
    # dotnet
    dotnetCombined
    aspnetCombined
    inputs.zen-browser.packages.${pkgs.system}.default
    # Provide libpipewire for Qt multimedia
    pkgs.pipewire
  ];

  # Ensure Aspire workload is available with the installed .NET SDKs
  system.activationScripts.dotnet-aspire-install.text = ''
    runuser -l mariogk -c "${dotnetCombined}/bin/dotnet workload install aspire"
    runuser -l mariogk -c "${dotnetCombined}/bin/dotnet workload install wasm-tools"
    runuser -l mariogk -c "${dotnetCombined}/bin/dotnet workload install wasm-experimental"
    runuser -l mariogk -c "${dotnetCombined}/bin/dotnet workload install wasi-experimental"
  '';

  # Ensure user mariogk owns the configuration directory for git operations
  system.activationScripts.nixos-directory-permissions.text = ''
    chown -R mariogk:mariogk /etc/nixos
  '';

  # Ensure the PowerShell profile in this repository is installed for the user
  system.activationScripts.powershell-profile.text = ''
    profileDir="/home/mariogk/.config/powershell"
    install -Dm644 ${../files/powershell/profile.ps1} "$profileDir/Microsoft.PowerShell_profile.ps1"
    chown mariogk:mariogk "$profileDir/Microsoft.PowerShell_profile.ps1"
  '';

  # Install Terminal-Icons module for PowerShell if missing
  system.activationScripts.terminal-icons-install.text = ''
    runuser -l mariogk -c 'pwsh -NoProfile -NonInteractive -Command "if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) { Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force }"'
  '';

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs; };
    users.mariogk = import ../home/mariogk.nix;
  };

  # Default system state version
  system.stateVersion = "25.05";
}

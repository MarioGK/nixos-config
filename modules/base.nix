{ config, pkgs, inputs, ... }:

let
  dotnetCombined =
    (with pkgs.dotnetCorePackages;
      combinePackages [ dotnet_10.sdk dotnet_9.sdk ]);
  aspnetCombined =
    (with pkgs.dotnetCorePackages;
      combinePackages [ aspnetcore_10_0-bin aspnetcore_9_0 ]);
in
{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable networking
  networking.networkmanager.enable = true;

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


  # Disable CUPS printer service.
  services.printing.enable = false;

  # Enable sound with pipewire.
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
    extraGroups = [ "networkmanager" "wheel" ];
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
    pkgs.powershell
    pkgs.oh-my-posh
    pkgs.nerd-fonts.jetbrains-mono
    jetbrains.rider
    pkgs.legcord
    #kde
    kdePackages.kscreen
    # dotnet
    dotnetCombined
    aspnetCombined
    inputs.zen-browser.packages.${pkgs.system}.default
  ];

  # Ensure Aspire workload is available with the installed .NET SDKs
  system.activationScripts.dotnet-aspire-install.text = ''
    runuser -l mariogk -c "${dotnetCombined}/bin/dotnet workload install aspire"
  '';

  # Ensure user mariogk owns the configuration directory for git operations
  system.activationScripts.nixos-directory-permissions.text = ''
    chown -R mariogk:mariogk /etc/nixos
  '';

  # Default system state version
  system.stateVersion = "25.05";
}


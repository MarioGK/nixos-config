{
  config,
  pkgs,
  inputs,
  hostname,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./dotnet.nix
  ];

  # Boot configuration
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "mitigations=off" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # Nix configuration
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Networking
  networking = {
    wireless.iwd.enable = true;
    networkmanager = {
      enable = true;
      insertNameservers = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      wifi.backend = "iwd";
    };
  };

  # Locale and timezone
  time.timeZone = "America/Sao_Paulo";
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

  # Wayland-only configuration
  services.xserver.enable = false;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;
  programs.dconf.enable = true;

  # Exclude unnecessary KDE packages
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    oxygen
  ];

  # Audio configuration
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  hardware.enableRedistributableFirmware = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;

  # User configuration
  users.users.mariogk = {
    isNormalUser = true;
    description = "Mario Gabriell Karaziaki";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.powershell;
  };

  # Security configuration
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.user == "mariogk") {
        return polkit.Result.YES;
      }
    });
  '';

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

  # Auto-login
  services.displayManager.autoLogin = {
    enable = true;
    user = "mariogk";
  };

  # Shell configuration
  users.defaultUserShell = pkgs.powershell;
  environment.shells = with pkgs; [ powershell ];

  # Essential programs
  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  # Base system packages
  environment.systemPackages = with pkgs; [
    powershell
    pipewire
    bluez
    bluez-tools
    wl-clipboard
  ];

  # Home manager configuration
  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { 
      inherit inputs;
      inherit hostname;
    };
    users.mariogk = import ../home/mariogk.nix;
  };

  system.stateVersion = "25.05";
}

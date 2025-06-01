{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./dotnet.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "mitigations=off" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Enable networking
  networking = {
    # Use the iNet Wireless Daemon instead of wpa_supplicant
    wireless.iwd.enable = true;

    # Enable NetworkManager and configure it to use iwd
    networkmanager = {
      enable = true;
      insertNameservers = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      wifi.backend = "iwd";
    };
  };

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

  # Audio settings
  # Include redistributable firmware like audio codecs
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

  hardware.bluetooth = {
    enable = true;
    #powerOnBoot = true;
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

  # Install firefox
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Packages installed in system profile
  environment.systemPackages = with pkgs; [
    pkgs.nano
    pkgs.wget
    pkgs.git
    pkgs.htop
    pkgs.btop
    pkgs.powershell
    wayland-utils
    wl-clipboard
    libva-utils
    vulkan-tools
    pkgs.zoxide
    # Audio
    pkgs.pipewire
    bluez
    bluez-tools
    pkgs.pavucontrol
    pkgs.pamixer
  ];

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs; };
    users.mariogk = import ../home/mariogk.nix;
  };

  # Default system state version
  system.stateVersion = "25.05";
}

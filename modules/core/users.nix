{ config, lib, pkgs, ... }:

{
  users.users.mariogk = {
    isNormalUser = true;
    description = "Mario";
    extraGroups = [
      "wheel"           # sudo access
      "networkmanager"  # Network configuration
      "video"           # GPU access
      "audio"           # Audio access
      "input"           # Input devices
      "dialout"         # Serial ports
      "podman"          # Container management
    ];
    shell = pkgs.fish;
  };

  # Enable fish system-wide for completions
  programs.fish.enable = true;

  # Security settings
  security = {
    # Polkit for privilege escalation
    polkit.enable = true;

    # Sudo configuration
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      extraConfig = ''
        Defaults timestamp_timeout=30
      '';
    };

    # RTKit for real-time audio
    rtkit.enable = true;
  };

  # Enable PAM for swaylock/kde unlock
  security.pam.services.login.enableGnomeKeyring = true;
}

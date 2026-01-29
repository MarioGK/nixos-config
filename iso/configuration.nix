{ config, lib, pkgs, ... }:

{
  # Override hostname for live environment
  networking.hostName = lib.mkForce "nixos-live";

  # Give nixos user same groups as mariogk
  users.users.nixos = {
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "podman" ];
    shell = pkgs.fish;
  };

  # Auto-login for live environment
  services.greetd.settings.initial_session = {
    command = "startplasma-wayland";
    user = "nixos";
  };

  # Pre-clone the config repository on first boot
  system.activationScripts.cloneConfig = ''
    if [ ! -d /home/nixos/nixos-config ]; then
      ${pkgs.git}/bin/git clone https://github.com/MarioGK/nixos-config.git /home/nixos/nixos-config || true
      chown -R nixos:users /home/nixos/nixos-config 2>/dev/null || true
    fi
  '';

  # Create sops directory structure
  system.activationScripts.sopsSetup = ''
    mkdir -p /home/nixos/.config/sops/age
    chown -R nixos:users /home/nixos/.config/sops
  '';

  # Setup instructions on desktop
  system.activationScripts.setupInstructions = ''
    mkdir -p /home/nixos/Desktop
    cat > /home/nixos/Desktop/SETUP.md << 'EOF'
# Quick Setup

1. Connect to network
2. Run: rbw register && rbw sync
3. Get age key: rbw get "SOPS Age Key" > ~/.config/sops/age/keys.txt
4. SSH keys now work via rbw agent
EOF
    chown -R nixos:users /home/nixos/Desktop
  '';

  # Disable services that don't make sense for live
  services.syncthing.enable = lib.mkForce false;

  # ISO naming
  isoImage.isoName = lib.mkForce "nixos-mariogk-live.iso";

  # Extra tools for installation
  environment.systemPackages = with pkgs; [
    gparted
    ntfs3g
  ];
}

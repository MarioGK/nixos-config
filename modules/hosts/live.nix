{ config, lib, inputs, ... }:

let
  nixosModules = with config.flake.modules.nixos; [
    # Base system (no boot.nix - ISO handles bootloader)
    base-networking
    base-nix
    base-audio
    base-bluetooth

    # Desktop
    desktop-plasma
    desktop-fonts

    # Shell
    shell-fish

    # Development
    dev-core
    dev-containers

    # Services (subset appropriate for live)
    service-flatpak
    service-ssh

    # Overlays (no secrets for live)
    overlays
  ];

  homeModules = with config.flake.modules.homeManager; [
    # Desktop
    desktop-plasma

    # Shell & programs
    shell-fish
    programs-git
    programs-desktop
    programs-terminals
  ];
in
{
  flake.nixosConfigurations.live = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      # Base ISO module with Plasma 6 and Calamares installer
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
    ] ++ nixosModules ++ [
      # ISO-specific configuration
      ({ config, lib, pkgs, ... }: {
        # Override hostname for live environment
        networking.hostName = lib.mkForce "nixos-live";

        # Use SDDM from ISO module instead of greetd
        services.greetd.enable = lib.mkForce false;
        services.displayManager.sddm.enable = lib.mkForce true;

        # Give nixos user same groups as mariogk
        users.users.nixos = {
          extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "podman" ];
          shell = pkgs.fish;
        };

        # Auto-login for live environment (SDDM autologin)
        services.displayManager.autoLogin = {
          enable = true;
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
        image.fileName = lib.mkForce "nixos-mariogk-live.iso";

        # Extra tools for installation
        environment.systemPackages = with pkgs; [
          gparted
          ntfs3g
        ];
      })

      # Home Manager integration for nixos user
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
          users.nixos = { config, lib, pkgs, ... }: {
            imports = homeModules;
            home = {
              username = "nixos";
              homeDirectory = "/home/nixos";
              stateVersion = "24.11";
            };
            programs.home-manager.enable = true;

            # XDG directories
            xdg = {
              enable = true;
              userDirs = {
                enable = true;
                createDirectories = true;
                desktop = "${config.home.homeDirectory}/Desktop";
                documents = "${config.home.homeDirectory}/Documents";
                download = "${config.home.homeDirectory}/Downloads";
                music = "${config.home.homeDirectory}/Music";
                pictures = "${config.home.homeDirectory}/Pictures";
                videos = "${config.home.homeDirectory}/Videos";
              };
            };

            # Disable rbw services (user registers manually on live ISO)
            systemd.user.services.rbw-agent = lib.mkForce { };
            systemd.user.services.rbw-sync = lib.mkForce { };
            systemd.user.timers.rbw-sync = lib.mkForce { };

            # Session variables
            home.sessionVariables = {
              EDITOR = "code --wait";
              VISUAL = "code --wait";
            };
          };
        };
      }
    ];
  };
}

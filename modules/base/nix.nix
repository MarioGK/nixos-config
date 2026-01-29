{ config, lib, inputs, ... }:

{
  flake.modules.nixos.base-nix = { config, lib, pkgs, ... }: {
    nix = {
      # Enable flakes and new nix command
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;

        # Parallel downloads and builds
        max-jobs = "auto";              # Build jobs in parallel (auto = number of CPUs)
        cores = 0;                       # Cores per job (0 = all available)
        http-connections = 50;           # Parallel HTTP connections for downloads
        max-substitution-jobs = 128;     # Parallel substitution (download) jobs

        # Trusted users for remote builds
        trusted-users = [ "root" "@wheel" ];

        # Substituters for faster builds
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
        ];

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };

      # Garbage collection
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };

      # Pin nixpkgs registry to the flake input
      registry.nixpkgs.flake = inputs.nixpkgs;

      # Pin NIX_PATH for legacy commands
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Locale settings
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_TIME = "pt_BR.UTF-8";
        LC_MONETARY = "pt_BR.UTF-8";
        LC_NUMERIC = "pt_BR.UTF-8";
        LC_MEASUREMENT = "pt_BR.UTF-8";
        LC_PAPER = "pt_BR.UTF-8";
      };
    };

    # Timezone
    time.timeZone = "America/Sao_Paulo";

    # Console keyboard
    console.keyMap = "us";

    # X11/Wayland keyboard
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # System packages for nix management
    environment.systemPackages = with pkgs; [
      git  # Required for flakes
      nix-output-monitor  # Better build output
      nvd  # Nix version diff
      comma  # Run any package without installing
      manix  # Search Nix documentation
      nixpkgs-fmt  # Nix code formatter
    ];
  };
}

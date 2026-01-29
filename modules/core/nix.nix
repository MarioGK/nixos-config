{ config, lib, pkgs, inputs, ... }:

{
  nix = {
    # Enable flakes and new nix command
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;

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

  # System packages for nix management
  environment.systemPackages = with pkgs; [
    git  # Required for flakes
    nix-output-monitor  # Better build output
    nvd  # Nix version diff
  ];
}

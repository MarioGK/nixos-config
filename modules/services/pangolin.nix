{ config, lib, pkgs, ... }:

{
  # Newt - Pangolin tunnel client
  # https://docs.pangolin.net/
  services.newt = {
    enable = true;

    # Configure via sops-nix secrets or set directly
    # settings = {
    #   endpoint = "https://pangolin.example.com";
    #   id = "your-site-id";
    #   secret = "your-site-secret";  # Use sops for this
    # };
  };

  # Newt CLI tool
  environment.systemPackages = with pkgs; [
    newt
  ];
}

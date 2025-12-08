{ config, pkgs, lib, ... }:

{
  options = {
    profiles = {
      development = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable development tools and packages";
      };
      
      gaming = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable gaming-related packages and configurations";
      };
      
      multimedia = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable multimedia and creative tools";
      };
      
      laptop-specific = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable laptop-specific optimizations and tools";
      };
      
      desktop-specific = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable desktop-specific optimizations and tools";
      };
    };
  };

  config = {
    # Development profile
    environment.systemPackages = with pkgs; lib.optionals config.profiles.development [
      git
      wget
      nano
      htop
      btop
      zoxide
      nixfmt-rfc-style
    ];

    # Gaming profile
    environment.systemPackages = with pkgs; lib.optionals config.profiles.gaming [
      vulkan-tools
      libva-utils
      wayland-utils
    ];

    # Multimedia profile
    environment.systemPackages = with pkgs; lib.optionals config.profiles.multimedia [
      pavucontrol
      pamixer
    ];

    # Laptop-specific profile
    environment.systemPackages = with pkgs; lib.optionals config.profiles.laptop-specific [
      powertop
    ];

    # Desktop-specific profile
    environment.systemPackages = with pkgs; lib.optionals config.profiles.desktop-specific [
      lact
      radeontop
    ];
  };
}
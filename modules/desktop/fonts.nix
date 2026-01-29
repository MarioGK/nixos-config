{ config, lib, pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      # Microsoft fonts compatibility
      corefonts
      vistafonts

      # Google fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji

      # Coding fonts
      jetbrains-mono
      fira-code
      cascadia-code

      # Nerd fonts (for terminal)
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.meslo-lg

      # System fonts
      liberation_ttf
      ubuntu_font_family
      inter

      # Icons
      font-awesome
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" "Liberation Serif" ];
        sansSerif = [ "Inter" "Noto Sans" "Liberation Sans" ];
        monospace = [ "JetBrains Mono" "Fira Code" ];
        emoji = [ "Noto Color Emoji" ];
      };

      # Better font rendering
      hinting = {
        enable = true;
        style = "slight";
      };
      antialias = true;
      subpixel.rgba = "rgb";
    };
  };
}

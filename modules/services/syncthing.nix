{ config, lib, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    user = "mariogk";
    dataDir = "/home/mariogk";
    configDir = "/home/mariogk/.config/syncthing";

    # Open Web UI only on localhost
    guiAddress = "127.0.0.1:8384";

    # Override devices and folders via the Web UI
    # These are just defaults, actual config is in syncthing's config.xml
    overrideDevices = false;
    overrideFolders = false;
  };

  # Syncthing ports are opened in networking.nix
}

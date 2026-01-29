{ config, lib, pkgs, ... }:

{
  # ananicy-cpp - Process priority optimization
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-cpp-rules;
  };

  # earlyoom - Early OOM killer
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    extraArgs = [
      "--avoid" "^(firefox|zen|code|rider)$"
      "--prefer" "^(Web Content|Isolated Web)$"
    ];
  };

  # libnotify for earlyoom notifications
  environment.systemPackages = [ pkgs.libnotify ];
}

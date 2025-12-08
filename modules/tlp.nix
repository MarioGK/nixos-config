{ config, pkgs, ... }:
let
  # Determine if we should enable TLP: only when the machine-level
  # `powerManagement.enable` is set (e.g. on the laptop host).
  tlpEnabled = if (config ? powerManagement) && (config.powerManagement ? enable)
    then config.powerManagement.enable
    else false;
in
{
  # Disable power-profiles-daemon as it conflicts with TLP, but only when
  # TLP is actually enabled. If TLP is disabled leave the existing
  # `services.power-profiles-daemon.enable` value alone (or false if unset).
  services.power-profiles-daemon.enable = if tlpEnabled then false
    else (if (config.services ? power-profiles-daemon) && (config.services.power-profiles-daemon ? enable)
      then config.services.power-profiles-daemon.enable
      else false);

  services.tlp = {
    enable = tlpEnabled;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance-power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 60;
      CPU_BOOST_ON_BAT = 1;
      SCHED_POWERSAVE_ON_BAT = 1;

      #Optional helps save long term battery health
      START_CHARGE_THRESH_BAT0 = 60;
      STOP_CHARGE_THRESH_BAT0 = 90;

    };
  };
}

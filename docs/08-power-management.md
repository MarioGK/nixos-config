# Power Management

This guide covers laptop power management using TLP and related optimizations.

## Overview

Power management is crucial for laptops to extend battery life while maintaining performance when needed. NixOS provides several tools for this purpose, with TLP being the most comprehensive.

## TLP Configuration

TLP (TLP Linux Advanced Power Management) handles automatic power optimization without requiring manual intervention.

### Enabling TLP

```nix
# modules/tlp.nix
{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.powerManagement.enable {
    # Disable power-profiles-daemon (conflicts with TLP)
    services.power-profiles-daemon.enable = false;

    services.tlp = {
      enable = true;
      settings = {
        # CPU scaling governors
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";

        # CPU frequency limits (percentage)
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 60;

        # Enable CPU boost
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 1;

        # Battery charge thresholds (preserves battery health)
        START_CHARGE_THRESH_BAT0 = 60;
        STOP_CHARGE_THRESH_BAT0 = 90;
      };
    };
  };
}
```

### CPU Governors Explained

| Governor | Description | Use Case |
|----------|-------------|----------|
| `performance` | Always max frequency | AC power, demanding tasks |
| `schedutil` | Kernel-integrated, balanced | Battery, general use |
| `powersave` | Always min frequency | Maximum battery life |
| `ondemand` | Scales based on CPU load | Legacy systems |

### Battery Charge Thresholds

Limiting charge to 80-90% extends battery lifespan significantly:

```nix
START_CHARGE_THRESH_BAT0 = 60;  # Start charging at 60%
STOP_CHARGE_THRESH_BAT0 = 90;   # Stop charging at 90%
```

**Note**: Not all laptops support charge thresholds. ThinkPads have excellent support.

## Profile Integration

Enable power management in your laptop profile:

```nix
# profiles/laptop.nix
{ config, lib, pkgs, ... }:
{
  powerManagement.enable = true;

  # Import TLP module
  imports = [ ../modules/tlp.nix ];
}
```

## Additional Power Tools

### Powertop

Analyze power consumption and identify inefficiencies:

```nix
profiles.laptop-specific = true;  # Includes powertop
```

Usage:
```bash
# Run power analysis
sudo powertop

# Auto-tune (one-time)
sudo powertop --auto-tune
```

### thermald

Intel thermal management daemon:

```nix
services.thermald.enable = true;
```

## Monitoring Power Usage

```bash
# Show battery status
cat /sys/class/power_supply/BAT0/status
cat /sys/class/power_supply/BAT0/capacity

# Show current governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# Show TLP status
sudo tlp-stat -s
sudo tlp-stat -b  # Battery info
```

## Best Practices

1. **Use schedutil on battery** - Modern kernels integrate it well with the scheduler
2. **Set charge thresholds** - 60-90% range extends battery life by years
3. **Avoid powersave governor** - Often causes lag without significant power savings
4. **Monitor with powertop** - Identify power-hungry applications
5. **Keep firmware updated** - Often includes power management improvements

## Troubleshooting

### TLP Not Starting

Check if power-profiles-daemon conflicts:
```bash
systemctl status power-profiles-daemon
systemctl status tlp
```

### Charge Thresholds Not Working

Verify your hardware supports it:
```bash
sudo tlp-stat -b
```

Look for "charge thresholds = supported" in the output.

## Related Documentation

- [Best Practices](06-best-practices.md) - System maintenance guidelines
- [Hardware Configs](12-hardware-configs.md) - Hardware-specific settings
- [Profile System](10-profile-system.md) - Enabling laptop profiles

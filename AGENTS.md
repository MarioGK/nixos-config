# Repository Overview

This repository contains NixOS configuration using flakes. The hosts are organized under `hosts/` with hardware-specific modules in `hardware/`.

## Hardware Summary
- **Laptop**: Lenovo Yoga Aura Edition (Slim 7 14ILL10) with a Lunar Lake CPU.
- **Desktop**: AMD Ryzen 7 5800X CPU paired with an AMD Radeon 7700XT GPU.

These machines use the configurations in `hosts/laptop` and `hosts/desktop` respectively.

##

It should avoid xserver and x11 and try to do everything with wayland only


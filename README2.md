---
author: Matthias Benaets
description: General information about my flake and how to set it up
title: Matthias\' NixOS & Nix-Darwin System Configuration Flake
---

```{=org}
#+attr_org: :width 600
```
[]{.image}

# Table of Content [[toc]{.smallcaps}]{.tag tag-name="toc"} {#table-of-content}

- [Table of Content [[toc]{.smallcaps}]{.tag tag-name="toc"} {#table-of-content}](#table-of-content-tocsmallcapstag-tag-nametoc-table-of-content)
- [System Components](#system-components)
- [NixOS Installation Guide](#nixos-installation-guide)
  - [Partitioning](#partitioning)
    - [UEFI](#uefi)
    - [Legacy](#legacy)
  - [Installation](#installation)
    - [UEFI](#uefi-1)
    - [Legacy](#legacy-1)
    - [Mounting Extras](#mounting-extras)
    - [Generate](#generate)
    - [Possible Extra Steps](#possible-extra-steps)
    - [Install](#install)
  - [Finalization](#finalization)
- [Nix Installation Guide](#nix-installation-guide)
  - [Installation](#installation-1)
    - [Initial](#initial)
    - [Rebuild](#rebuild)
  - [Finalization](#finalization-1)
- [Nix-Darwin Installation Guide](#nix-darwin-installation-guide)
  - [Setup](#setup)
  - [Installation](#installation-2)
    - [Initial](#initial-1)
    - [Rebuild](#rebuild-1)
  - [Finalization](#finalization-2)
- [FAQ](#faq)

# System Components

                      **NixOS - Xorg**    **NixOS - Wayland**   **Darwin**
  ------------------- ------------------- --------------------- -------------------
  **Shell**           Zsh                 Zsh                   Zsh
  **DM**              LightDM             TTY1 Login            /
  **WM**              Bspwm               Hyprland              Yabai
  **Compositor**      Picom (jonaburg)    Hyprland              /
  **Bar**             Polybar             Waybar                /
  **Hotkeys**         Sxhkd               Hyprland              Skhd
  **Launcher**        Rofi                Rofi                  /
  **GTK Theme**       Dracula             Dracula               /
  **Notifications**   Dunst               Dunst                 /
  **Terminal**        Alacritty           Alacritty             Alacritty
  **Editor**          Nvim + Doom Emacs   Nvim + Doom Emacs     Nvim + Doom Emacs
  **Used by host**    Desktop & VM        Desktop & Laptop      Macbook

There are some other desktop environments/window manager. Just link to
correct default.nix in `~/hosts/<host>/default.nix`

# NixOS Installation Guide

This flake currently has **3** hosts

1.  desktop
    -   UEFI boot w/ systemd-boot
2.  laptop
    -   UEFI boot w/ grub (Dual Boot)
3.  vm
    -   Legacy boot w/ grub

Flakes can be build with:

-   `$ sudo nixos-rebuild switch --flake <path>#<hostname>`
-   example `$ sudo nixos-rebuild switch --flake .#desktop`

## Partitioning

This will depend on the host chosen.

### UEFI

**In these commands**

-   Partition Labels:
    -   Boot = \"boot\"
    -   Home = \"nixos\"
-   Partition Size:
    -   Boot = 512MiB
    -   Swap = 8GiB
    -   Home = Rest
-   No Swap: Ignore line 3 & 7

```{=html}
<!-- -->
```
    # parted /dev/sda -- mklabel gpt
    # parted /dev/sda -- mkpart primary 512MiB -8GiB
    # parted /dev/sda -- mkpart primary linux-swap -8GiB 100%
    # parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
    # parted /dev/sda -- set 3 esp
    # mkfs.ext4 -L nixos /dev/sda1
    # mkswap -L /dev/sda2
    # mkfs.fat -F 32 -n boot /dev/sda3

### Legacy

**In these commands**

-   Partition Label:
    -   Home & Boot = \"nixos\"
    -   Swap = \"swap\"
-   Partition Size:
    -   Swap = 8GiB
    -   Home = Rest
-   No swap: Ignore line 3 and 5

```{=html}
<!-- -->
```
    # parted /dev/sda -- mklabel msdos
    # parted /dev/sda -- mkpart primary 1MiB -8GiB
    # parted /dev/sda -- mkpart primary linux-swap -8GiB 100%
    # mkfs.ext4 -L nixos /dev/sda1
    # mkswap -L /dev/sda2

## Installation

### UEFI

**In these commands**

-   Partition with label ... to ...
    -   \"nixos\" -\> `/mnt`
    -   \"boot\" -\> `/mnt/boot`

```{=html}
<!-- -->
```
    # mount /dev/disk/by-label/nixos /mnt
    # mkdir -p /mnt/boot
    # mount /dev/disk/by-label/boot /mnt/boot

### Legacy

    # mount /dev/disk/by-label/nixos /mnt

### Mounting Extras

**In these commands**

-   `/mnt/ssd`

```{=html}
<!-- -->
```
-   Label of storage:
    -   ssd2
-   If storage has no label:
    -   `mount /dev/disk/by-uuid/ssd2 /mnt/ssd`

```{=html}
<!-- -->
```
    # mkdir -p /mnt/ssd
    # mount /dev/disk/by-label/ssd2 /mnt/ssd

### Generate

**In these commands**

-   Swap is enable:
    -   Ignore if no swap or enough RAM
-   Configuration files are generated @ `/mnt/etc/nixos`
    -   If you are me, you don\'t need to do this.
        Hardware-configuration.nix already in flake.
-   Clone repository

```{=html}
<!-- -->
```
    # swapon /dev/sda2
    # nixos-generate-config --root /mnt
    # nix-env -iA nixos.git
    # git clone https://github.com/MarioGK/nixos-config /mnt/etc/nixos/<name>

    Optional if you are not me
    # cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/nixos-config/hosts/<host>/.

### Possible Extra Steps

1.  Switch specific host hardware-configuration.nix with generated
    `/mnt/etc/nixos/hardware-configuration.nix`
2.  Change existing network card name with the one in your system
    -   Look in generated hardware-configuration.nixos
    -   Or enter `$ ip a`
3.  Change username in flake.nix
4.  Set a `users.users.${user}.initialPassword = ...`
    -   Not really recommended. It\'s maybe better to follow last steps
5.  If you are planning on using default2.nix doom emacs, don\'t forget
    to rebuild after the initial installation when you link to this nix
    file.
    -   Don\'t forget to change the flake location in flake.nix
    -   This is because userActivationScript is used for the setup and
        some locations are partially hardcoded
    -   It will automatically install if `~/.emacs.d` does not exist

### Install

**In these commands**

-   Move into cloned repository
    -   in this example `/mnt/etc/nixos/<name>`
-   Available hosts:
    -   desktop
    -   laptop
    -   vm

```{=html}
<!-- -->
```
    # cd /mnt/etc/nixos/<name>
    # nixos-install --flake .#<host>

## Finalization

1.  Set a root password after installation is done
2.  Reboot without livecd
3.  Login
    1.  If initialPassword is not set use TTY:
        -   `Ctrl - Alt - F1`
        -   login as root
        -   `# passwd <user>`
        -   `Ctrl - Alt - F7`
        -   login as user
4.  Optional:
    -   `$ sudo mv <location of cloned directory> <prefered location>`
    -   `$ sudo chown -R <user>:users <new directory>`
    -   `$ sudo rm /etc/nixos/configuration.nix`
    -   or just clone flake again do apply same changes.
5.  Dual boot:
    -   OSProber probably did not find your Windows partion after the
        first install
    -   There is a high likelyhood it will find it after:
        -   `$ cd <repo directory>`
        -   `$ sudo nixos-rebuild switch --flake .#<host>`
6.  Rebuilds:
    -   `<flakelocation>$ sudo nixos-rebuild switch --flake .#<host>`

# Nix Installation Guide

This flake currently has **1** host

1.  pacman

The Linux distribution must have the nix package manager installed.
`$ sh <(curl -L https://nixos.org/nix/install) --daemon` To be able to
have a easy reproducible setup when using the nix package manager on a
non-NixOS system, home-manager is a wonderful tool to achieve this. So
this is how it is set up in this flake.

## Installation

### Initial

**In these commands**

-   Get git
-   Clone repository
-   First build of the flake
    -   This is done so we can use the nix flake commands

```{=html}
<!-- -->
```
    $ nix-env -iA nixpkgs.git
    $ git clone https://github.com/MarioGK/nixos-config ~/.setup
    $ cd ~/.setup
    $ nix build --extra-experimental-features 'nix-command flakes' .#homeConfigurations.<host>.activationPackage
    $ ./result/activate

### Rebuild

Since home-manager is now a valid command we can rebuild the system
using this command. In this example it is build from inside the flake
directory:

-   `$ home-manager switch --flake .#<host>`

This will rebuild the configuration and automatically activate it.

## Finalization

**Mostly optional or already correct by default**

1.  NixGL gets set up by default, so if you are planning on using GUI
    applications that use OpenGL or Vulkan:
    -   `$ nixGLIntel <package>`
    -   or add it to your aliasses file
2.  Every rebuild, and activation-script will run to add applications to
    the system menu.
    -   it\'s pretty much the same as adding the path to XDG~DATADIRS~
    -   if you do not want to or if the locations are different, change
        this.

# Nix-Darwin Installation Guide

This flake currently has **1** host

1.  macbook

The Apple computer must have the nix package manager installed.
`$ sh <(curl -L https://nixos.org/nix/install)`

## Setup

**In these commands**

-   Create a nix config directory
-   Allow experimental features to use flakes

```{=html}
<!-- -->
```
    $ mkdir ~/.config/nix
    $ echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

## Installation

### Initial

**In these commands**

-   Get git
-   Clone repository
-   First build of the flake on Darwin
    -   This is done because the darwin command is not yet available

```{=html}
<!-- -->
```
    $ nix-env -iA nixpkgs.git
    $ git clone https://github.com/MarioGK/nixos-config ~/.setup
    $ cd ~/.setup
    $ nix build .#darwinConfigurations.<host>.system
    $ ./result/sw/bin/darwin-rebuild switch --flake .#<host>

`/result` is located depending on where you build the system.

### Rebuild

Since darwin is now added to the PATH, you can build it from anywhere in
the system. In this example it is rebuild from inside the flake
directory:

-   `$ darwin-rebuild switch --flake .#<host>`

This will rebuild the configuration and automatically activate it.

## Finalization

**Mostly optional or already correct by default**

1.  Change default shell for Terminal or iTerm.
    -   `Terminal/iTerm > Preferences > General > Shells open with: Command > /bin/zsh`
2.  Disable Secure Keyboard Entry. Needed for Skhd.
    -   `Terminal/iTerm > Secure Keyboard Entry`
3.  Install XCode to get complete development environment.
    -   `$ xcode-select --install`

# FAQ

-   What is NixOS?
    -   NixOS is a Linux distribution built on top of the Nix package
        manager.
    -   It uses declarative configurations and allow reliable system
        upgrades.
-   What is a Flake?
    -   Flakes are an upcoming feature of the Nix package manager.
    -   Flakes allow you to specify your major code dependencies in a
        declarative way.
    -   It does this by creating a flake.lock file. Some major code
        dependencies are:
        -   nixpkgs
        -   home-manager
-   What is Nix-Darwin?
    -   Nix-Darwin is a way to use Nix modules on macOS using the Darwin
        Unix-based core set of components.
    -   Just like NixOS, it allows to build declarative reproducible
        configurations.
-   Should I switch to NixOS?
    -   Is water wet?
-   Where can I learn about everything Nix?
    -   Nix and NixOS
        -   [My General Setup Guide](nixos.org)
        -   [Website](https://nixos.org/)
        -   [Manuals](https://nixos.org/learn.html)
        -   [Manual
            2](https://nixos.org/manual/nix/stable/introduction.html)
        -   [Packages](https://search.nixos.org/packages) and
            [Options](https://search.nixos.org/options?)
        -   [Unofficial Wiki](https://nixos.wiki/)
        -   [Wiki Resources](https://nixos.wiki/wiki/Resources)
        -   [Nix Pills](https://nixos.org/guides/nix-pills/)
        -   [Some](https://www.ianthehenry.com/posts/how-to-learn-nix/)
            [Blogs](https://christine.website/blog)
        -   [Config
            Collection](https://nixos.wiki/wiki/Configuration_Collection)
        -   [Config
            Collection](https://nixos.wiki/wiki/Configuration_Collection)
    -   Home-manager
        -   [Official
            Repo](https://github.com/nix-community/home-manager)
        -   [Manual](https://nix-community.github.io/home-manager/)
        -   [Appendix
            A](https://nix-community.github.io/home-manager/options.html)
        -   [Appendix
            B](https://nix-community.github.io/home-manager/nixos-options.html)
        -   [Appendix
            D](https://nix-community.github.io/home-manager/tools.html)
        -   [NixOS wiki](https://nixos.wiki/wiki/Home_Manager)
    -   Flakes
        -   [NixOS wiki](https://nixos.wiki/wiki/Flakes)
        -   [Manual](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html)
        -   [Some](https://www.tweag.io/blog/2020-05-25-flakes/)
            [Blogs](https://christine.website/blog/nix-flakes-3-2022-04-07)
    -   Nix-Darwin
        -   [My General Setup Guide](darwin.org)
        -   [Official Repo](https://github.com/LnL7/nix-darwin/)
        -   [Manual](https://daiderd.com/nix-darwin/manual/index.html)
        -   [Mini-Wiki](https://github.com/LnL7/nix-darwin/wiki)
    -   Videos
        -   [My Personal Mini-Course](https://youtu.be/AGVXJ-TIv3Y)
        -   [Wil T\'s
            Playlist](https://www.youtube.com/watch?v=QKoQ1gKJY5A&list=PL-saUBvIJzOkjAw_vOac75v-x6EzNzZq)
        -   [Burke Libbey\'s
            Nixology](https://www.youtube.com/watch?v=NYyImy-lqaA&list=PLRGI9KQ3_HP_OFRG6R-p4iFgMSK1t5BHs)
        -   [John Ringer\'s
            Channel](https://www.youtube.com/user/elitespartan117j27/videos)

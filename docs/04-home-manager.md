# Home Manager

## What is Home Manager?

Home Manager is a tool for managing user environments using Nix. While NixOS configures the system, Home Manager configures user-specific settings:

| NixOS | Home Manager |
|-------|--------------|
| System packages | User packages |
| System services | User services |
| `/etc` files | `~/.config` files |
| Root-level config | Dotfiles |

## When to Use Each

### Use NixOS for:
- System services (nginx, postgresql, docker)
- Hardware configuration
- Boot settings
- System-wide packages
- Network configuration
- Users and groups

### Use Home Manager for:
- Shell configuration (bash, zsh, fish)
- Editor settings (neovim, emacs, vscode)
- Git configuration
- Desktop applications
- Dotfiles
- User systemd services

## Integration Methods

### 1. NixOS Module (Recommended)

Home Manager as a NixOS module—single rebuild command:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.myuser = import ./home.nix;

          # Pass arguments to home.nix
          home-manager.extraSpecialArgs = {
            inherit inputs;
          };
        }
      ];
    };
  };
}
```

```nix
# home.nix
{ config, pkgs, ... }:
{
  home.username = "myuser";
  home.homeDirectory = "/home/myuser";
  home.stateVersion = "24.11";

  programs.git = {
    enable = true;
    userName = "My Name";
    userEmail = "email@example.com";
  };
}
```

Rebuild with:
```bash
sudo nixos-rebuild switch --flake .#myhost
```

### 2. Standalone

Home Manager separate from NixOS—useful for non-NixOS systems:

```nix
# flake.nix
{
  outputs = { nixpkgs, home-manager, ... }: {
    homeConfigurations."myuser@myhost" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./home.nix ];
    };
  };
}
```

Rebuild with:
```bash
home-manager switch --flake .#myuser@myhost
```

## Using `follows`

Keep Home Manager using the same nixpkgs version:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";  # Important!
  };
};
```

Without `follows`, Home Manager would use its own nixpkgs, potentially causing:
- Version mismatches
- Duplicate packages in the store
- Inconsistent behavior

## Common Configurations

### Shell (Zsh)

```nix
{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -la";
      update = "sudo nixos-rebuild switch --flake .";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" ];
      theme = "robbyrussell";
    };
  };
}
```

### Neovim

```nix
{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      telescope-nvim
      catppuccin-nvim
    ];

    extraLuaConfig = ''
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true
    '';
  };
}
```

### Git

```nix
{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "you@example.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };

    delta = {
      enable = true;  # Better diffs
      options = {
        navigate = true;
        side-by-side = true;
      };
    };

    aliases = {
      co = "checkout";
      br = "branch";
      st = "status";
      lg = "log --oneline --graph";
    };
  };
}
```

## plasma-manager Integration

For KDE Plasma desktop configuration:

```nix
# flake.nix inputs
inputs = {
  plasma-manager = {
    url = "github:nix-community/plasma-manager";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };
};
```

```nix
# home.nix
{ inputs, ... }:
{
  imports = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];

  programs.plasma = {
    enable = true;

    workspace = {
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      cursorTheme = "Breeze";
      lookAndFeel = "org.kde.breezedark.desktop";
    };

    hotkeys.commands = {
      "launch-terminal" = {
        key = "Meta+Return";
        command = "konsole";
      };
    };

    panels = [
      {
        location = "bottom";
        height = 44;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          "org.kde.plasma.taskmanager"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];

    kwin = {
      borderlessMaximizedWindows = true;
    };
  };
}
```

## Dotfiles Management

### Direct Configuration

Most programs have Home Manager modules:

```nix
{
  programs.starship = {
    enable = true;
    settings = {
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
    };
  };
}
```

### Raw Dotfiles

For programs without modules, use `home.file`:

```nix
{
  home.file = {
    ".config/myapp/config.toml".text = ''
      [settings]
      theme = "dark"
    '';

    # Copy from source
    ".config/myapp/data".source = ./dotfiles/myapp/data;

    # Recursive directory
    ".config/nvim" = {
      source = ./dotfiles/nvim;
      recursive = true;
    };
  };
}
```

### XDG Configuration

```nix
{
  xdg.configFile = {
    "myapp/config.toml".text = ''
      [settings]
      theme = "dark"
    '';
  };

  xdg.dataFile = {
    "myapp/data.json".source = ./data.json;
  };
}
```

## User Services

```nix
{
  systemd.user.services.my-daemon = {
    Unit = {
      Description = "My background daemon";
      After = [ "graphical-session-pre.target" ];
    };
    Service = {
      ExecStart = "${pkgs.my-daemon}/bin/my-daemon";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
```

## Further Reading

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)
- [plasma-manager](https://github.com/nix-community/plasma-manager)
- [NixOS Wiki - Home Manager](https://wiki.nixos.org/wiki/Home_Manager)

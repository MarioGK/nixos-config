# Flake Structure

## Basic Anatomy

Every `flake.nix` file has this basic structure:

```nix
{
  description = "A description of your flake";

  inputs = {
    # External dependencies
  };

  outputs = { self, nixpkgs, ... }: {
    # What this flake provides
  };
}
```

## Complete Example

```nix
{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/myhost/configuration.nix
          home-manager.nixosModules.home-manager
        ];
      };
    };
}
```

## Inputs

Inputs declare external dependencies your flake needs.

### Input URL Formats

```nix
inputs = {
  # GitHub repository (most common)
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  # Specific branch
  nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

  # Specific commit
  nixpkgs-pinned.url = "github:NixOS/nixpkgs/abc123...";

  # GitLab
  something.url = "gitlab:owner/repo";

  # Local path (for development)
  local-flake.url = "path:/home/user/projects/my-flake";

  # Tarball URL
  templates.url = "https://example.com/templates.tar.gz";

  # Git URL (any git host)
  custom.url = "git+https://git.example.com/repo.git";

  # Flake in subdirectory
  subdir.url = "github:owner/repo?dir=subdir";
};
```

### Input Follows

Use `follows` to make inputs share the same version of a dependency:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  home-manager = {
    url = "github:nix-community/home-manager";
    # Use the same nixpkgs as the parent flake
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Multiple levels of follows
  plasma-manager = {
    url = "github:nix-community/plasma-manager";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };
};
```

### Non-Flake Inputs

For inputs that aren't flakes (e.g., data files, Vim plugins):

```nix
inputs = {
  # Vim plugin (not a flake)
  vim-plugin = {
    url = "github:author/vim-plugin";
    flake = false;
  };

  # Use in outputs
  # pkgs.vimUtils.buildVimPlugin { src = vim-plugin; }
};
```

## Outputs

Outputs define what your flake provides. The function receives all inputs as arguments.

### Output Types

```nix
outputs = { self, nixpkgs, ... }: {
  # NixOS system configurations
  nixosConfigurations.hostname = nixpkgs.lib.nixosSystem { ... };

  # Home Manager configurations (standalone)
  homeConfigurations."user@host" = home-manager.lib.homeManagerConfiguration { ... };

  # Packages
  packages.x86_64-linux.default = pkgs.hello;
  packages.x86_64-linux.myapp = pkgs.callPackage ./myapp.nix {};

  # Development shells
  devShells.x86_64-linux.default = pkgs.mkShell { ... };

  # Overlays
  overlays.default = final: prev: { ... };

  # NixOS modules
  nixosModules.default = import ./modules/my-module.nix;

  # Templates
  templates.default = {
    path = ./template;
    description = "A starter template";
  };

  # Formatter (for `nix fmt`)
  formatter.x86_64-linux = pkgs.nixpkgs-fmt;
};
```

### The `self` Argument

`self` refers to the flake itself, useful for:

```nix
outputs = { self, nixpkgs, ... }: {
  nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
    modules = [
      # Reference other outputs from this flake
      self.nixosModules.my-module

      # Access the flake's source directory
      { environment.etc."flake-source".source = self; }
    ];
  };
};
```

## Lock Files

### What is flake.lock?

The `flake.lock` file pins all inputs to specific revisions:

```json
{
  "nodes": {
    "nixpkgs": {
      "locked": {
        "lastModified": 1234567890,
        "narHash": "sha256-...",
        "owner": "NixOS",
        "repo": "nixpkgs",
        "rev": "abc123...",
        "type": "github"
      }
    }
  }
}
```

### Managing Lock Files

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake update nixpkgs

# Update multiple inputs
nix flake update nixpkgs home-manager

# Show current locked versions
nix flake metadata

# Don't commit flake.lock changes yet
nix flake update --commit-lock-file  # Creates a commit
```

### Lock File Best Practices

1. **Always commit `flake.lock`**: It ensures reproducibility
2. **Update regularly**: Security updates, bug fixes
3. **Update incrementally**: Update one input at a time to identify breaking changes
4. **Test after updates**: Rebuild and verify before committing

## nixConfig Attribute

Optional settings that apply when evaluating the flake:

```nix
{
  nixConfig = {
    # Binary caches
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = { ... };
  outputs = { ... };
}
```

**Note**: Users will be prompted to trust these settings.

## Further Reading

- [Nix Flakes Reference](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html)
- [Flake Schema](https://wiki.nixos.org/wiki/Flakes#Flake_schema)

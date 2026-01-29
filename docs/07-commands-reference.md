# Commands Reference

## nix flake Commands

### Initialize and Inspect

```bash
# Create new flake in current directory
nix flake init

# Create from template
nix flake init -t github:misterio77/nix-starter-configs#standard

# Show flake outputs
nix flake show

# Show flake metadata (inputs, locked versions)
nix flake metadata

# Check flake for errors
nix flake check
```

### Update Dependencies

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake update nixpkgs

# Update multiple specific inputs
nix flake update nixpkgs home-manager

# Update and create commit
nix flake update --commit-lock-file
```

### Lock File Management

```bash
# Show locked versions
nix flake metadata

# Lock to specific commit (in flake.nix, then update)
# inputs.nixpkgs.url = "github:NixOS/nixpkgs/abc123...";
nix flake update nixpkgs

# Override input temporarily (doesn't modify lock)
nix build --override-input nixpkgs github:NixOS/nixpkgs/nixos-24.11
```

## nixos-rebuild Commands

### Basic Operations

```bash
# Build and switch immediately
sudo nixos-rebuild switch --flake .#hostname

# Build and switch on next boot
sudo nixos-rebuild boot --flake .#hostname

# Build and test (no boot entry, switch back on reboot)
sudo nixos-rebuild test --flake .#hostname

# Build only (no activation)
nixos-rebuild build --flake .#hostname
```

### Advanced Options

```bash
# Show what would change (dry run)
nixos-rebuild dry-activate --flake .#hostname

# Build on remote machine
nixos-rebuild switch --flake .#hostname --target-host user@remote

# Build remotely, deploy locally
nixos-rebuild switch --flake .#hostname --build-host user@builder

# Use specific nixpkgs
nixos-rebuild switch --flake .#hostname -I nixpkgs=/path/to/nixpkgs

# Show build logs
nixos-rebuild switch --flake .#hostname -L

# Fast rebuild (skip evaluation cache)
nixos-rebuild switch --flake .#hostname --fast
```

### Rollback

```bash
# Switch to previous generation
sudo nixos-rebuild switch --rollback

# List generations
sudo nix-env --list-generations -p /nix/var/nix/profiles/system

# Switch to specific generation
sudo nix-env --switch-generation 42 -p /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch

# Delete old generations (keep last 5)
sudo nix-env --delete-generations +5 -p /nix/var/nix/profiles/system
```

## home-manager Commands

### Standalone Mode

```bash
# Build and switch
home-manager switch --flake .#user@hostname

# Build only
home-manager build --flake .#user@hostname

# Show generations
home-manager generations

# Remove old generations
home-manager expire-generations "-7 days"
```

### NixOS Module Mode

When Home Manager is a NixOS module, use `nixos-rebuild`:

```bash
# Applies both NixOS and Home Manager config
sudo nixos-rebuild switch --flake .#hostname
```

## Debugging Commands

### nix repl

```bash
# Start REPL with nixpkgs
nix repl '<nixpkgs>'

# Start REPL with flake
nix repl
:lf .  # Load flake from current directory

# In REPL
nixosConfigurations.hostname.config.services.nginx
nixosConfigurations.hostname.config.environment.systemPackages
pkgs.hello.meta
:q  # Quit
```

### nix eval

```bash
# Evaluate expression
nix eval .#nixosConfigurations.hostname.config.networking.hostName

# Evaluate nixpkgs attribute
nix eval nixpkgs#hello.version

# Pretty print
nix eval --json .#nixosConfigurations.hostname.config.users.users | jq
```

### Build and Inspect

```bash
# Build with debug output
nix build .#nixosConfigurations.hostname.config.system.build.toplevel -L

# Show derivation
nix derivation show .#nixosConfigurations.hostname.config.system.build.toplevel

# Show build dependencies
nix-store -q --references /nix/store/...-nixos-system-hostname

# Show runtime dependencies
nix-store -q --requisites /nix/store/...-nixos-system-hostname

# Why is package in closure?
nix why-depends .#nixosConfigurations.hostname.config.system.build.toplevel nixpkgs#openssl
```

## Package Management

### Search and Info

```bash
# Search packages
nix search nixpkgs firefox

# Show package info
nix eval nixpkgs#firefox.meta --json | jq

# List package outputs
nix derivation show nixpkgs#firefox
```

### Try Packages

```bash
# Run package without installing
nix run nixpkgs#hello

# Enter shell with package
nix shell nixpkgs#python3 nixpkgs#nodejs

# Run in pure shell (no inherited env)
nix shell nixpkgs#python3 --ignore-environment
```

### Build Packages

```bash
# Build package
nix build nixpkgs#hello

# Build and don't create result symlink
nix build nixpkgs#hello --no-link

# Build with different system
nix build nixpkgs#hello --system aarch64-linux
```

## Store Management

### Garbage Collection

```bash
# Delete unreferenced store paths
nix-collect-garbage

# Delete old generations and collect garbage
nix-collect-garbage -d

# Delete generations older than 14 days
nix-collect-garbage --delete-older-than 14d

# Free at least 10GB
nix-collect-garbage --max-freed 10G
```

### Store Operations

```bash
# Optimize store (hard link duplicates)
nix store optimise

# Verify store integrity
nix store verify --all

# Show store path info
nix path-info /nix/store/...-hello

# Show store path size
nix path-info -S /nix/store/...-hello

# Show closure size
nix path-info -rS /nix/store/...-hello
```

### Query Store

```bash
# Find store path for package
nix build nixpkgs#hello --print-out-paths

# List contents of store path
ls $(nix build nixpkgs#hello --print-out-paths --no-link)

# Find what depends on a store path
nix-store -q --referrers /nix/store/...-openssl
```

## Profile Management

```bash
# List profiles
ls /nix/var/nix/profiles/

# Show system generations
sudo nix-env -p /nix/var/nix/profiles/system --list-generations

# Show per-user generations
nix-env --list-generations

# Delete old generations
nix-env --delete-generations old
nix-env --delete-generations 1 2 3
nix-env --delete-generations +5  # Keep last 5
```

## Useful Aliases

Add to your shell config:

```bash
# Quick rebuild
alias nrs="sudo nixos-rebuild switch --flake ."
alias nrt="sudo nixos-rebuild test --flake ."
alias nrb="nixos-rebuild build --flake ."

# Flake operations
alias nfu="nix flake update"
alias nfs="nix flake show"

# Garbage collection
alias ngc="nix-collect-garbage -d"

# Search
alias ns="nix search nixpkgs"

# Try packages
alias nr="nix run nixpkgs#"
alias nsh="nix shell nixpkgs#"
```

## Common Workflows

### Full System Update

```bash
# Update flake inputs
nix flake update

# Test build
nixos-rebuild build --flake .#hostname

# Test without persisting
sudo nixos-rebuild test --flake .#hostname

# If good, switch
sudo nixos-rebuild switch --flake .#hostname

# Clean up
nix-collect-garbage -d
```

### Debug Build Failure

```bash
# Build with verbose output
nix build .#package -L

# Keep failed build directory
nix build .#package --keep-failed

# Build in debug shell
nix develop .#package
# Then run build phases manually
unpackPhase
patchPhase
configurePhase
buildPhase
```

### Deploy to Remote

```bash
# Build locally, deploy remotely
nixos-rebuild switch --flake .#remotehost \
  --target-host user@remote \
  --use-remote-sudo
```

## Further Reading

- [Nix Manual - Commands](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix.html)
- [NixOS Manual - nixos-rebuild](https://nixos.org/manual/nixos/stable/#sec-changing-config)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)

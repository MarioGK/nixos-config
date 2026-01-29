# Nix Flakes Overview

## What Are Flakes?

Flakes are a feature in Nix that provide a standardized way to write Nix expressions with explicit dependency declarations. Think of them as `package.json` for the Nix ecosystem—they declare what your project needs and lock those dependencies to specific versions.

A flake is any directory containing a `flake.nix` file that follows a specific schema.

## Why Use Flakes?

### Problems Flakes Solve

1. **Reproducibility**: Traditional Nix configurations could reference `<nixpkgs>` which pointed to whatever version was on your system. Flakes lock dependencies to exact commits.

2. **Dependency Declaration**: All external inputs must be explicitly declared. No more hidden dependencies on channels or environment variables.

3. **Standardized Structure**: Every flake follows the same schema, making it easier to understand and share configurations.

4. **Hermetic Evaluation**: Flakes are evaluated in pure mode by default—no access to environment variables or impure builtins.

### Before Flakes
```nix
# Could use different nixpkgs versions on different machines
{ pkgs ? import <nixpkgs> {} }:
# ...
```

### With Flakes
```nix
# Explicitly declares and locks nixpkgs version
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  # Version locked in flake.lock
}
```

## Key Benefits

| Feature | Without Flakes | With Flakes |
|---------|---------------|-------------|
| Dependency versions | Implicit (channels) | Explicit (flake.lock) |
| Reproducibility | Best effort | Guaranteed |
| Sharing configs | Manual setup | Clone and build |
| Evaluation | Impure by default | Pure by default |
| Schema | None | Standardized |

## Limitations

1. **Experimental Status**: Flakes are still technically "experimental" though widely adopted. Enable with:
   ```nix
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   ```

2. **Git-Tracked Only**: Flakes only see files tracked by Git. New files must be `git add`ed before they're visible.

3. **Learning Curve**: Different mental model from traditional Nix channels.

4. **No Dynamic Inputs**: Inputs are fixed at evaluation time; you can't compute them.

## Enabling Flakes

### In configuration.nix (NixOS)
```nix
{ pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

### In nix.conf (Non-NixOS)
```ini
# ~/.config/nix/nix.conf
experimental-features = nix-command flakes
```

### Temporary (Per-Command)
```bash
nix --experimental-features 'nix-command flakes' build
```

## Flake Registry

Nix maintains a registry that provides shortcuts for common flakes:

```bash
# These are equivalent:
nix shell nixpkgs#hello
nix shell github:NixOS/nixpkgs#hello

# View registry
nix registry list
```

## Further Reading

- [NixOS Wiki - Flakes](https://wiki.nixos.org/wiki/Flakes)
- [Determinate Systems - Nix Flakes Explained](https://determinate.systems/blog/nix-flakes-explained/)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/)
- [Zero to Nix - Flakes](https://zero-to-nix.com/concepts/flakes)

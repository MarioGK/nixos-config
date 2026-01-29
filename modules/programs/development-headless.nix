{ config, lib, pkgs, ... }:

let
  # .NET with workload support workaround
  dotnet-combined = (with pkgs.dotnetCorePackages; combinePackages [
    sdk_10_0
    aspnetcore_10_0
  ]).overrideAttrs (finalAttrs: previousAttrs: {
    postBuild = (previousAttrs.postBuild or "") + ''
      for i in $out/sdk/*; do
        i=$(basename $i)
        length=$(printf "%s" "$i" | wc -c)
        substring=$(printf "%s" "$i" | cut -c 1-$(expr $length - 2))
        i="$substring""00"
        mkdir -p $out/metadata/workloads/''${i/-*}
        touch $out/metadata/workloads/''${i/-*}/userlocal
      done
    '';
  });
in
{
  # Development tools (headless - no GUI applications)
  environment.systemPackages = with pkgs; [
    # Version control
    git
    gh  # GitHub CLI
    lazygit
    gitui

    # .NET
    dotnet-combined

    # Python
    python3
    python3Packages.pip
    pipx

    # Node.js / JavaScript
    nodejs_22
    nodePackages.npm
    nodePackages.pnpm
    yarn
    bun

    # Go
    go

    # Rust
    rustup

    # Build tools
    gnumake
    cmake
    ninja
    pkg-config

    # AI tools
    claude-code
    # opencode  # Disabled: requires bun which uses CPU instructions not available on all systems

    # CLI utilities
    jq
    yq
    httpie
    curl
    wget

    # System utilities
    ncdu       # Disk usage analyzer
    gping      # Ping with graph
    duf        # Better df
    dust       # Better du

    # Container tools
    lazydocker  # Docker/Podman TUI

    # Debugging
    gdb
    strace
    ltrace
  ];

  # .NET environment
  # Workloads are installed to ~/.dotnet/workloads (writable location)
  environment.variables = {
    DOTNET_ROOT = "${dotnet-combined}";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    # Enable workload installation to user directory instead of read-only Nix store
    DOTNET_CLI_HOME = "$HOME/.dotnet";
  };

  # Ensure .dotnet directory structure exists for workloads
  environment.etc."profile.d/dotnet-workloads.sh".text = ''
    # Create directories for .NET workloads if they don't exist
    mkdir -p "$HOME/.dotnet/workloads"
    mkdir -p "$HOME/.dotnet/metadata/workloads"

    # Add local tools to PATH
    export PATH="$HOME/.dotnet/tools:$PATH"

    # Auto-install wasm-tools workload if not present
    if ! dotnet workload list 2>/dev/null | grep -q "wasm-tools"; then
      echo "Installing .NET wasm-tools workload..."
      dotnet workload install wasm-tools --skip-sign-check 2>/dev/null || true
    fi
  '';

  # Development-related services
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}

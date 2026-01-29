{ config, lib, pkgs, ... }:

let
  # .NET with workload support workaround
  dotnet-combined = (with pkgs.dotnetCorePackages; combinePackages [
    sdk_9_0
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
  # Development tools
  environment.systemPackages = with pkgs; [
    # Version control
    git
    gh  # GitHub CLI
    lazygit

    # .NET
    dotnet-combined

    # Python
    python3
    python3Packages.pip
    pipx

    # Node.js
    nodejs_22
    nodePackages.npm
    nodePackages.pnpm
    yarn

    # Go
    go

    # Rust
    rustup

    # Build tools
    gnumake
    cmake
    ninja
    pkg-config

    # Editors and IDEs
    vscode
    jetbrains-toolbox

    # AI tools
    claude-code

    # CLI utilities
    jq
    yq
    httpie
    curl
    wget

    # Debugging
    gdb
    strace
    ltrace
  ];

  # .NET environment
  environment.variables = {
    DOTNET_ROOT = "${dotnet-combined}";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
  };

  # Development-related services
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}

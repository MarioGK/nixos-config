{ inputs }:

[
  # Zen Browser overlay
  inputs.zen-browser.overlays.default

  # Custom overlays
  (final: prev: {
    # Helium Browser from flake
    helium-browser = inputs.helium-browser.packages.${prev.system}.default;

    # OpenCode from flake
    opencode = inputs.opencode.packages.${prev.system}.default;
  })
]

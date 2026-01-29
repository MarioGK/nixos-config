{ inputs }:

[
  # Custom overlays
  (final: prev: {
    # Zen Browser from flake
    zen-browser = inputs.zen-browser.packages.${prev.system}.default or inputs.zen-browser.packages.${prev.system}.zen-browser or null;

    # Helium Browser from flake
    helium-browser = inputs.helium-browser.packages.${prev.system}.default or null;

    # OpenCode from flake
    opencode = inputs.opencode.packages.${prev.system}.default or null;
  })
]

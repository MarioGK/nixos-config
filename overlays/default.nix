{ inputs }:

[
  # Zen Browser overlay
  inputs.zen-browser.overlays.default

  # Custom overlays
  (final: prev: {
    # Add custom package modifications here
    # example = prev.example.override { ... };
  })
]

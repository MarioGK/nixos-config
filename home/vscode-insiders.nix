{
  # This file defines an overlay for VS Code Insiders.
  # It can be imported into a home-manager configuration.
}:
{
  nixpkgs.overlays = [(final: prev: {
    vscode-insiders = (prev.vscode.override {
      isInsiders = true;
    }).overrideAttrs (oldAttrs: rec {
      pname = oldAttrs.pname + "-insiders"; # e.g., code-insiders
      version = "latest_insider"; # A distinct version string, actual version usually derived by build
      src = final.fetchurl {
        url = "https://update.code.visualstudio.com/latest/linux-x64/insider";
        name = "vscode-insiders-linux-x64-latest.tar.gz";
        sha256 = "0000000000000000000000000000000000000000000000000000"; # Placeholder, to be updated by just script
      };
      # Disable nix's default update script if any, as updates are handled by the just script.
      passthru = oldAttrs.passthru // {
        updateScript = null;
      };
    });
  })];
}

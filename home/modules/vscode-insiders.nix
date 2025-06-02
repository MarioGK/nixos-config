{ config, pkgs, lib, ... }: # Added lib for mkIf if we use options later

let
  vscode-insiders-with-extensions = pkgs.vscode-with-extensions.override {
    vscodeExtensions = with pkgs.vscode-extensions; [
      ms-python.python
      bbenoist.nix
      # Add other extensions here if needed
    ];
    vscode = (pkgs.vscode.override { isInsiders = true; }).overrideAttrs (oldAttrs: rec {
      src = (builtins.fetchTarball {
        url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
        # IMPORTANT: This SHA256 is a placeholder and will need to be updated by the user
        # after the first build attempt fails and provides the correct hash.
        sha256 = "0s0s0s0s0s0s0s0s0s0s0s0s0s0s0s0s0s0s0s0s0s0s0s0s0s0s";
      });
      version = "latest"; # This will use the version from the tarball
      # buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ]; # krb5 was in the original snippet, ensure it's needed or remove
    });
  };
in
{
  home.packages = [
    vscode-insiders-with-extensions
  ];

  programs.bash.enable = true; # Ensures bash settings can be applied
  programs.bash.shellAliases = {
    code = "code-insiders";
  };

  # Optional: Define an enable option if you prefer that pattern
  # options.programs.vscode-insiders.enable = lib.mkEnableOption "VSCode Insiders support";
  #
  # config = lib.mkIf config.programs.vscode-insiders.enable {
  #   home.packages = [ vscode-insiders-with-extensions ];
  #
  #   programs.bash.enable = true;
  #   programs.bash.shellAliases = {
  #     code = "code-insiders";
  #   };
  # };
}

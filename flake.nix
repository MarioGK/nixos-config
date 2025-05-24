{
  description = "NixOS configuration for multiple machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, zen-browser }:
    let
      system = "x86_64-linux";
      mkHost = hostPath: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ hostPath ];
        specialArgs = { inherit inputs; };
      };

      laptop = mkHost ./hosts/laptop;
      desktop = mkHost ./hosts/desktop;
    in {
      nixosConfigurations = {
        laptop = laptop;
        desktop = desktop;
        # Provide a default configuration under the name 'nixos'
        # so that plain `nixos-rebuild switch` works out of the box.
        nixos = laptop;
      };
    };
}

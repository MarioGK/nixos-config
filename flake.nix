{
  description = "NixOS configuration for multiple machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      mkHost = hostPath: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ hostPath ];
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

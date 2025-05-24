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
    in {
      nixosConfigurations = {
        laptop = mkHost ./hosts/laptop;
        desktop = mkHost ./hosts/desktop;
      };
    };
}

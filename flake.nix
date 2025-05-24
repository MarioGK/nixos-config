{
  description = "NixOS configuration for multiple machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, zen-browser, home-manager, plasma-manager }:
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
        # Alias for laptop so that `nixos-rebuild switch` works on host
        # `mario-laptop` without explicitly specifying the flake output
        mario-laptop = laptop;
        mario-desktop = desktop;
        # Provide a default configuration under the name 'nixos'
        # so that plain `nixos-rebuild switch` works out of the box.
        nixos = laptop;
      };
    };
}

{
  description = "NixOS configuration for mariogk";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, sops-nix, zen-browser, ... }@inputs:
    let
      lib = import ./lib { inherit inputs; };
    in
    {
      nixosConfigurations = {
        mariogk-notebook = lib.mkHost {
          hostname = "mariogk-notebook";
          system = "x86_64-linux";
        };
      };
    };
}

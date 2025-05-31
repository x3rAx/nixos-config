{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    nixpkgs-unstable-overlay = {...}: {
      nixpkgs.overlays = [
        (final: prev: {
          unstable = import nixpkgs-unstable final;
        })
      ];
    };

    specialArgs = {
      inherit inputs;
    };
  in {
    nixosConfigurations."K1STE" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs =
        specialArgs
        // {
          hostname = "K1STE";
        };
      modules = [
        nixpkgs-unstable-overlay
        ./configuration.nix
      ];
    };
    nixosConfigurations."Jehuty" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs =
        specialArgs
        // {
          hostname = "Jehuty";
        };
      modules = [
        nixpkgs-unstable-overlay
        ./configuration.nix
      ];
    };
  };
}

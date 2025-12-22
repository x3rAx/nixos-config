{
  description = "My NixOS configuration";

  #nixConfig = {
  #  extra-substituters = [
  #    #"https://hyprland.cachix.org"
  #    #"https://nix-gaming.cachix.org"
  #  ];
  #  extra-trusted-public-keys = [
  #    #"hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
  #    #"nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
  #  ];
  #};

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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

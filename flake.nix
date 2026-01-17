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

    copy-extra-config-files = {myLib, ...}: {
      system.systemBuilderCommands = myLib.createCopyExtraConfigFilesScript [
        ./flake.nix
        ./flake.lock
        ./configuration.nix
        ./modules
      ];
    };

    # Add symlink to the flake used to build the derivation in `$out/_flake`
    symlink-flake = {...}: {
      system.extraSystemBuilderCmds = ''
        ln -s ${self.outPath} $out/_flake
      '';
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
        symlink-flake
        copy-extra-config-files
        nixpkgs-unstable-overlay
        ./modules
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
        symlink-flake
        copy-extra-config-files
        nixpkgs-unstable-overlay
        ./modules
        ./configuration.nix
      ];
    };
  };
}

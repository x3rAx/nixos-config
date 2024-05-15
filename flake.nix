{
    description = "My NixOS configuration";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
        let
            system = "x86_64-linux";

            # Create Nixpkgs with config from a custom input
            mkNixpkgs = custom_nixpkgs: config:
                import custom_nixpkgs ({ inherit system; } // config);
            mkUnstable = config: mkNixpkgs nixpkgs-unstable config;

            specialArgs = {
                inherit inputs;
                inherit mkNixpkgs;
                inherit mkUnstable;
            };

        in {
            nixosConfigurations."K1STE" = nixpkgs.lib.nixosSystem {
                inherit system;
                specialArgs = specialArgs // {
                    hostname = "K1STE";
                };
                modules = [
                    ./configuration.nix
                ];
            };
        };
}

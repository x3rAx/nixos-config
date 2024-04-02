{
    description = "My NixOS configuration";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    };

    outputs = { self, nixpkgs, ... }@inputs: {
        nixosConfigurations."K1STE" = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = inputs // {
                hostname = "K1STE";
            };
            modules = [
                ./configuration.nix
            ];
        };
    };
}

{ config, pkgs, ... }:

let
    lib = import ./lib.nix;
    hostname = import ./hostname.nix;
in {
    imports = [
        (lib.toPath "./configuration/${hostname}/configuration.nix")
    ];

    system.activationScripts = {
        symlinkCurrentHost = {
            deps = [];
            text = ''
                link='/etc/nixos/current-host'
                dest='/etc/nixos/configuration/${hostname}'

                ln -sfr -T "$dest" "$link"
            '';
        };
    };
}

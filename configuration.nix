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
                ln -sf "/etc/nixos/configuration/${hostname}" "/etc/nixos/.current-host.tmp"
                mv /etc/nixos/.current-host.tmp /etc/nixos/current-host # atomically replace it
            '';
        };
    };
}

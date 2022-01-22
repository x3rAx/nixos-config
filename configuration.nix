{ config, pkgs, ... }:

let
    lib = import ./lib.nix;
    hostname = import ./hostname.nix;
in {
    imports = [
        (lib.toPath "./configuration/${hostname}/configuration.nix")
    ];
}

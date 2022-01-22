{ config, pkgs, ... }:

let
    lib = import ./lib.nix;
    hostname = import ./hostname.nix;
in {
    imports = [
        (lib.toPath "./systems/${hostname}/configuration.nix")
    ];
}

args@{ config, pkgs, ... }:

let
    hostname = import ./hostname.nix;
    myLib = (import ./myLib.nix) args;
in rec {
    _module.args.myLib = myLib;

    imports = [
        (myLib.toPath "./configuration/${hostname}/configuration.nix")
    ];
    system.extraSystemBuilderCmds = myLib.createCopyExtraConfigFilesScript imports;

    nixpkgs.overlays = import ./overlays;

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

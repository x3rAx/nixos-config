args@{ config, pkgs, hostname, ... }:

let
    myLib = (import ./myLib.nix) args;
in rec {
    _module.args.myLib = myLib;

    imports = [
        (myLib.toPath "./configuration/${hostname}/configuration.nix")
    ];
    system.extraSystemBuilderCmds = myLib.createCopyExtraConfigFilesScript imports;

    nixpkgs.overlays = import ./overlays;

    # Enable the Flakes feature and the accompanying new nix command-line tool
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    environment.systemPackages = with pkgs; [
        # Flakes clones its dependencies through the git command,
        # so git must be installed first
        git
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

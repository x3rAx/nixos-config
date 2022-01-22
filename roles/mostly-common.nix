{ config, pkgs, ... }:

{
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        bc
        entr
        exa
        file
        fzf
        glances
        ncdu
        pv
        ranger
        trash-cli
        tree
        unzip
    ];
}

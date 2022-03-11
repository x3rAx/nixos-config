# Stuff that currently should be on all machines but has the potentil to be
# specific to only some machines in the future
{ config, pkgs, ... }:

{
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        btrfs-progs
        entr
        exa
        file
        fzf
        glances
        ncdu
        pv
        python3
        ranger
        trash-cli
        tree
        unzip
    ];

    # Select internationalisation properties.
    i18n = {
        # consoleFont = "Lat2-Terminus16";
        # consoleKeyMap = "us";
        supportedLocales = [
            "en_US.UTF-8/UTF-8"
            #"de_DE.UTF-8/UTF-8"
        ];
        defaultLocale = "en_US.UTF-8";
        #extraLocaleSettings = {
        #    # LANG is set by `i18n.defaultLocale`
        #    # LC_ALL = (unset)
        #    #LC_MEASUREMENT = "de_DE.UTF-8";
        #    #LC_MONETARY = "de_DE.UTF-8";
        #    #LC_COLLATE = "de_DE.UTF-8";
        #    #LC_NUMERIC = "de_DE.UTF-8";
        #    #LC_TIME = "de_DE.UTF-8";
        #};
    };

    # Set your time zone.
    time.timeZone = "Europe/Berlin";
    # TODO: Is it safe to do this everywhere?
    #time.hardwareClockInLocalTime = true;
}

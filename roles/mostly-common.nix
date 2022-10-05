# Stuff that currently should be on all machines but has the potentil to be
# specific to only some machines in the future
{ config, pkgs, ... }:

{
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        btrfs-progs
        docker-compose
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

    environment.shellAliases = {
        #doc = "docker-compose";
    };

    # Select internationalisation properties.
    i18n = {
        # consoleFont = "Lat2-Terminus16";
        # consoleKeyMap = "us";
        supportedLocales = [
            "en_US.UTF-8/UTF-8"
            "de_DE.UTF-8/UTF-8"
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

    programs.ssh.extraConfig = ''
        # Add the below line to the users `~/.ssh/config` to automatically add keys
        # when they are used.
        # DO NOT SET THIS HERE TO PREVENT LEAKING KEYS FROM SUDO TO REGULAR USER!
        #AddKeysToAgent yes|ask

        Host jarvis
            HostName jarvis.x3ro.net
            User x3ro

        Host badwolf
            HostName badwolf.x3ro.net
            User x3ro
    '';

    # Enable the OpenSSH daemon.
    services.openssh = {
        enable = true;
        passwordAuthentication = false;
        permitRootLogin = "prohibit-password";
        extraConfig = ''
            Match Address 127.0.0.1,::1
                PermitRootLogin prohibit-password
        '';
    };

    virtualisation.docker.enable = true;
}

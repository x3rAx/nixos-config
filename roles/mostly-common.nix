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
        iotop-c
        ncdu
        nfs-utils
        pv
        python3
        ranger
        trash-cli
        tree
        unzip
    ];

    environment.shellAliases = {
        iotop = "sudo iotop-c";
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
        # Add the below lines to the very bottom of the users `~/.ssh/config`
        # to automatically add keys when they are used (choose between "ask"
        # and "yes").
        #
        # !!! WARNING: DO NOT SET THIS HERE TO PREVENT LEAKING KEYS FROM SUDO TO REGULAR USER !!!
        #
        # ```
        # # NOTE: Keep this at the very bottom
        # Host *
        #     AddKeysToAgent yes|ask
        # # NOTE: Keep this at the very bottom
        # ```

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

    boot.enableContainers = false;
    virtualisation = {
        podman = {
            enable = true;

            # Create a `docker` alias for podman, to use it as a drop-in replacement
            #dockerCompat = true;

            # Required for containers under podman-compose to be able to talk to each other.
            # This is the definition that was outdated when I updated on 2023-01-09:
            defaultNetwork.dnsname.enable = true;
        };
    };

    environment.etc."NIXOS_LUSTRATE.template" = {
        mode = "0644";
        text = ''
            /etc/NIXOS_LUSTRATE.template

            /home
            /data
            /etc/secrets
            /swap

            /mnt
            /root
        '';
    };
}

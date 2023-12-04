# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, myLib, ... }:

rec {
    imports = [
        # Include the results of the hardware scan.
        ./hardware-configuration.nix
        ./hardware-override.nix
        ./openrgb.nix

        ../../roles/common.nix
        ../../roles/mostly-common.nix
        ../../roles/desktop.nix
        ../../roles/desktop-bspwm.nix
        ../../roles/nvidia.nix
    ];

    # Copies `configuration.nix` and links it from the resulting system to
    # `/run/current-system/configuration.nix`
    #system.copySystemConfiguration = true;
    # !!! DO NOT DO THIS --> # myLib.createCopyExtraConfigFilesScript [ ./. ] !!!
    system.extraSystemBuilderCmds = myLib.createCopyExtraConfigFilesScript ([ ./configuration.nix ] ++ imports);

    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        jack.enable = true;
    } // (
        if myLib.nixosMinVersion "23.05" then {
            # NOTE: Overriding default Pipewire configuration through NixOS
            #       options never worked correctly and is no longer supported.
            #       Please create drop-in files in
            #       /etc/pipewire/pipewire.conf.d/ to make the desired setting
            #       changes instead.
        } else {
            config.pipewire = {
                "context.properties" = {
                    #"link.max-buffers" = 64;
                    "link.max-buffers" = 16; # version < 3 clients can't handle more than this
                    "log.level" = 2; # https://docs.pipewire.org/page_daemon.html
                    #"default.clock.rate" = 48000;
                    #"default.clock.quantum" = 1024;
                    "default.clock.quantum" = 32;
                    #"default.clock.min-quantum" = 32;
                    "default.clock.min-quantum" = 32;
                    #"default.clock.max-quantum" = 8192;
                    "default.clock.max-quantum" = 2048;
                };
            };
        }
    );
    hardware.pulseaudio.enable = false;

    hardware.openrazer.enable = true;

    # Use the X configuration provided by the nvidia-settings tool
    #services.xserver.config = lib.mkAfter (builtins.readFile ./xserver-nvidia.conf);
    # For diagnostics, symlink the config to `/etc/X11/xorg.conf`
    services.xserver.exportConfiguration = true;
    boot.loader = {
        grub = {
            configurationName = "K1STE";
        };
    };

    boot.initrd.secrets = {
        # ATTENTION: Always use quotes for the paths. Otherwise the secret will be
        #            copied into the Nix store and will be WORLD READABLE!
        "/crypto_keyfile.bin" = "/etc/secrets/initrd/crypto_keyfile.bin";
    };

    boot.kernel.sysctl = {
        "kernel.sysrq" = 1; # Allow system request (e.g. "reisub")
        #"fs.inotify.max_user_watches" = 524288;
        #"vm.swappiness" = 1;
        "vm.max_map_count" = 16777216; # For StarCitizen
    };

    networking.hostName = "K1STE"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networking.networkmanager.enable = true;

    programs.gamemode.enable = true;
    programs.corectrl.enable = true;

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    networking.hosts = {
        #"127.0.0.1" = [ "myapp.local" ];
    };

    time.hardwareClockInLocalTime = true;

    environment.shellAliases = {
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        # Example: Build vscode with extra dependencies
        #(vscode.overrideAttrs (oldAttrs: {
        #  buildInputs = oldAttrs.buildInputs ++ [ polkit ];
        #}))

        bind
        cifs-utils # For mounting SMB
        glib
        hdparm
        pkg-config
        rnix-lsp
    ];


    # XSecureLock
    environment.etc."systemd/system-sleep/xsecurelock".source =
        pkgs.writeShellScript "xsecurelock" ''
            #!/bin/bash
            if [[ "$1" = "post" ]] ; then
              pkill -x -USR2 xsecurelock
            fi
            exit 0
            #if [ "$1-$SYSTEMD_SLEEP_ACTION" = "post-hibernate" ]; then
            #    ${pkgs.procps}/bin/pkill slock
            #fi
        '';


    # Enable Nvidia GPUs inside docker containers
    virtualisation.docker.enableNvidia = true;


    # Define a user account. Don't forget to set a password with ‘passwd’.
    # (generate hashed passwords with `mkpasswd -m sha512`)
    users.users.root = { hashedPassword = "!"; };
    users.users.x3ro = {
        isNormalUser = true;
        uid = 1000;
        extraGroups = [
            "wheel" # Enable ‘sudo’ for the user.
            "networkmanager"
            "docker"
            "vboxusers"
            "plugdev" # Enable access to keyboard eg. for ZSA Moonlander training tool
            "input"
            "tty"
            "libvirtd"
        ];
        initialPassword = "changeMe!";
    };


    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    #
    # When do I update `stateVersion`:
    #   https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "21.05"; # Did you read the comment?

}

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
    lib = import ../../lib.nix;
in rec {
    imports = [
        # Include the results of the hardware scan.
        ./hardware-configuration.nix
        ./encryption-configuration.nix

        ../../roles/common.nix
        ../../roles/mostly-common.nix
        ../../roles/desktop.nix
    ];

    # Copies `configuration.nix` and links it from the resulting system to
    # `/run/current-system/configuration.nix`
    #system.copySystemConfiguration = true;
    # !!! DO NOT DO THIS --> # lib.createCopyExtraConfigFilesScript [ ./. ] !!!
    system.extraSystemBuilderCmds = lib.createCopyExtraConfigFilesScript ([ ./configuration.nix ] ++ imports);

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
        "kernel.sysrq" = 1;
        #"fs.inotify.max_user_watches" = 524288;
        #"vm.swappiness" = 1;
    };

    networking.hostName = "K1STE"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networking.networkmanager.enable = true;

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    networking.useDHCP = false;
    networking.interfaces.enp3s0.useDHCP = true;

    programs.gamemode.enable = true;

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
        corectrl
        glib
        hdparm
        pkg-config
        rnix-lsp
    ];

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

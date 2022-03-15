# Configuration for workstations (desktops / laptops)
{ config, pkgs, ... }:

let
    lib = import ../lib.nix;

    baseconfig = { allowUnfree = true; };
    unstable = import <nixos-unstable> { config = baseconfig; };
    #pinned-for-virtualbox = builtins.fetchTarball {
    #    #name = "nixos-pinned-for-virtualbox";
    #    url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/21.11.tar.gz";
    #    sha256 = "162dywda2dvfj1248afxc45kcrg83appjd0nmdb541hl7rnncf02";
    #};
in rec {
    disabledModules = [
        #"virtualisation/virtualbox-host.nix"
    ];
    imports = [
        ../modules/nixos-rebuild-wrapper.nix
    ] ++ [
        # Overridden Modules
        #"${pinned-for-virtualbox}/nixos/modules/virtualisation/virtualbox-host.nix"
    ];
    system.extraSystemBuilderCmds = lib.createCopyExtraConfigFilesScript imports;

    # Enable Flakes
    nix = {
        package = pkgs.nixFlakes;
        extraOptions = ''
            # For nix-direnv
            keep-outputs = true
            keep-derivations = true
            # For nix flakes
            experimental-features = nix-command flakes
        '';
    };

    nixpkgs.overlays = [
        # Speech support for mumble
        (slef: super: {
            speechd = super.speechd.override {
                withEspeak = false; withPico = true; withFlite = false;
            };
                mumble = super.mumble.override {
                speechdSupport = true; 
            };
        })
    ];

    nixpkgs.config = baseconfig // {
        permittedInsecurePackages = [
            "electron-13.6.9" # For `super-productivity`
        ];
        # NOTE: This also replaces the packages when they are used as dependency
        #       for other packages
        packageOverrides = pkgs: {
            #inherit unstable;
            #gdu = unstable.gdu;
        };
    };

    boot.loader = {
        timeout = 1;
        efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/boot/efi";
        };
        grub = {
            enable = true;
            version = 2;
            device = "nodev";
            efiSupport = true;
            efiInstallAsRemovable = false;
            #configurationLimit = 100;
            memtest86.enable = true;
            backgroundColor = "#000000";
            splashImage = ../res/nixos-boot-background-scaled.png;
            # Get gfxmodes from the grub cli with `videoinfo`
            gfxmodeEfi = "1280x1024";
            enableCryptodisk = true;
            # - The option definition `boot.loader.grub.extraInitrd' in `/etc/nixos/configuration.nix' no longer has any effect; please remove it.
            # This option has been replaced with the bootloader agnostic
            # boot.initrd.secrets option. To migrate to the initrd secrets system,
            # extract the extraInitrd archive into your main filesystem:
            # 
            #   # zcat /boot/extra_initramfs.gz | cpio -idvmD /etc/secrets/initrd
            #   /path/to/secret1
            #   /path/to/secret2
            # 
            # then replace boot.loader.grub.extraInitrd with boot.initrd.secrets:
            # 
            #   boot.initrd.secrets = {
            #     "/path/to/secret1" = "/etc/secrets/initrd/path/to/secret1";
            #     "/path/to/secret2" = "/etc/secrets/initrd/path/to/secret2";
            #   };
            # 
            # See the boot.initrd.secrets option documentation for more information.
            #extraInitrd = /boot/initrd.keys.gz;
        };
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        # Custom derivations
    ] ++ [
        ack # Alternative grep "for sourcecode"
        alacritty
        anydesk
        appimage-run
        arandr
        ark # KDE archive gui (.tar.gz, etc.)
        audacious
        audacity
        autokey
        bashmount
        bc
        birdtray
        blanket
        borgbackup
        brave
        broot
        btop
        copyq
        cryptsetup
        delta # Better `git diff`
        deno
        direnv
        docker-compose
        dropbox
        entr
        escrotum
        ethtool
        exfat
        feh
        ferdi
        ferdi
        ffmpeg
        file
        firefox
        firefox
        fzf
        gimp
        gimp
        gitui
        glances
        glances
        gnumake # for `dake`
        handbrake
        httpie
        humanity-icon-theme # fix missing icons in virt-manager
        imagemagick
        inkscape
        jq
        keepassxc
        kopia
        ksnip
        libnotify
        libqalculate
        libreoffice
        lshw
        mariadb-client
        minio-client
        mpc-qt
        mtr
        mumble
        ncdu
        nix-direnv
        nodePackages.pnpm
        nodePackages.zx
        nodejs
        nodejs
        nomacs
        nox
        nushell
        obs-studio
        octave
        okular
        parted
        pciutils
        pdfmixtool
        picom-next
        playerctl # Control media players from cli
        polybar
        postman
        pv
        python3Packages.bpython # Alternative python repl
        quickemu
        ranger
        restic
        rofi
        rofi
        rofimoji
        rofimoji
        rustup
        rxvt-unicode
        sddm-kcm # For SDDM settings to appear in KDE settings
        shellcheck
        signal-desktop
        spotify
        super-productivity
        super-productivity
        sxhkd
        syncthing
        syncthing
        syncthingtray
        tdesktop # Telegram Desktop
        teamspeak_client
        thunderbird
        tmate
        tmate
        tor-browser-bundle-bin
        translate-shell
        tree
        trilium-desktop
        ueberzug # To show images in ranger
        unrar
        unzip
        usbutils
        ventoy-bin
        veracrypt
        virt-manager
        vlc
        vscode
        wally-cli # Mechanical keyboard flashing tool
        xclip
        xdotool #desktop
        xorg.xev
        xxd
        youtube-dl
        zip
    ];

    environment.shellAliases = {
        mnt = "bashmount";
        doc = "docker-compose";
        sudocode = "sudo -i code --user-data-dir /root/.config/sudocode";
        nixos-config = "sudocode /etc/nixos/{,{configuration,hardware-configuration}.nix}";
    };

    boot.supportedFilesystems = [ "ntfs-3g" ];

    console = {
        useXkbConfig = true;
        #font = "Lat2-Terminus16";
        #keyMap = "us";
    };

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;
    # services.xserver.libinput.touchpad.naturalScrolling = true;

    # Configure keymap in X11
    services.xserver.layout = "eu";
    #services.xserver.xkbOptions = "caps:escape";
    services.xserver.autoRepeatDelay = 200;
    services.xserver.autoRepeatInterval = 25; # 1000/25 = 40 keys/sec

    # Enable the Plasma 5 Desktop Environment.
    services.xserver.displayManager.sddm = {
        enable = true;
        autoNumlock = true;
        #enableHidpi = true;
    };
    services.xserver.windowManager.bspwm.enable = true;

    # Enable sound.
    sound.enable = true;
    hardware.pulseaudio.enable = true;

    # Enable udev rules for ZSA keyboards (Moonlander)
    hardware.keyboard.zsa.enable = true;

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
    programs.ssh.extraConfig = ''
        # Add the below line to the users `~/.ssh/config` to automatically add keys
        # when they are used.
        # DO NOT SET THIS HERE TO PREVENT LEAKING KEYS FROM SUDO TO REGULAR USER!
        #AddKeysToAgent yes

        Host jarvis
            HostName jarvis.x3ro.net
            User x3ro

        Host badwolf
            HostName badwolf.x3ro.net
            User x3ro
    '';
    programs.ssh.startAgent = true;

    programs.steam.enable = true;

    programs.dconf.enable = true;

    programs.kdeconnect.enable = true;

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    services.openssh = {
        enable = true;
        passwordAuthentication = false;
        permitRootLogin = "no";
        extraConfig = ''
            Match Address 127.0.0.1,::1
                PermitRootLogin prohibit-password
        '';
    };

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # Enable CUPS to print documents.
    services.printing.enable = true;
    
    # Enable Bluetooth
    #hardware.bluetooth.enable = true;

    hardware.logitech.wireless = {
        enable = true;
        enableGraphical = true; # Enables `solaar`
    };

    systemd.services.anydesk.enable = true;

    services = {
        syncthing = {
            enable = true;
            user = "x3ro";
            dataDir = "/home/x3ro/Syncthing";
            configDir = "/home/x3ro/.config/syncthing";
        };
    };

    # Logind config
    services.logind = {
        lidSwitch = "ignore";
        lidSwitchDocked = "ignore";
        lidSwitchExternalPower = "ignore";
        extraConfig = ''
            HandlePowerKey=hibernate
            HandleSuspendKey=suspend
            HandleHibernateKey=hibernate
            HandleRebootKey=reboot
        '';
    };

    system.activationScripts = {
        createMntDir = {
        deps = [];
        text = ''
            mkdir -p /mnt
        '';
        };
        addBinBash = {
        deps = [];
        text = ''
            mkdir -m 0755 -p /bin
            ln -sf "${pkgs.bash}/bin/bash" /bin/.bash.tmp
            mv /bin/.bash.tmp /bin/bash # atomically replace it
        '';
        };
        #fixVsCodeWriteAsSudo = {
        #    # GitHub issue: https://github.com/NixOS/nixpkgs/issues/49643
        #    text = ''
        #        mkdir -m 0755 -p /bin
        #        ln -sf "${pkgs.bash}/bin/bash" /bin/.bash.tmp
        #        mv /bin/.bash.tmp /bin/bash # atomically replace it
        #        ln -sf "${pkgs.polkit}/bin/pkexec" /usr/bin/.pkexec.tmp
        #        mv /usr/bin/.pkexec.tmp /usr/bin/pkexec # atomically replace it
        #    '';
        #    deps = [];
        #};
    };

    virtualisation.docker.enable = true;
    virtualisation.libvirtd.enable = true;
    #virtualisation.virtualbox.host = {
    #    enable = true;
    #    enableExtensionPack = true;
    #    package = pinned-for-virtualbox.pkgs.virtualbox;
    #};

}

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  baseconfig = { allowUnfree = true; };
  unstable = import <nixos-unstable> { config = baseconfig; };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./encryption-configuration.local.nix
  ];

  # NOTE: This also replaces the packages when they are used as dependency for
  #       other packages
  nixpkgs.config = baseconfig // {
    packageOverrides = pkgs: {
      gdu = unstable.gdu;
    };
  };

  # Copys `configuration.nix` and links it from the resulting system to `/run/current-system/configuration.nix`
  # TODO: Find a way to copy all config files that are imported
  system.copySystemConfiguration = true;
  # Copy other files to store and link them to `/run/current-system/`
  system.extraSystemBuilderCmds = ''
    # !!! DO NOT DO THIS !!! # ln -s ${./.} $out/full-config 
    ln -s ${./hardware-configuration.nix} $out/hardware-configuration.nix
    ln -s ${./encryption-configuration.local.nix} $out/encryption-configuration.local.nix
  '';

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
      configurationName = "K1STE";
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

  boot.supportedFilesystems = [ "ntfs-3g" ];

  networking.hostName = "K1STE"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp3s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.hosts = {
    #"127.0.0.1" = [ "myapp.local" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n = {
    # consoleFont = "Lat2-Terminus16";
    # consoleKeyMap = "us";
    supportedLocales = [
    	"en_US.UTF-8/UTF-8"
    	"de_DE.UTF-8/UTF-8"
    ];
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      # LANG is set by `i18n.defaultLocale`
      # LC_ALL = (unset)
      #LC_MEASUREMENT = "de_DE.UTF-8";
      #LC_MONETARY = "de_DE.UTF-8";
      #LC_COLLATE = "de_DE.UTF-8";
      #LC_NUMERIC = "de_DE.UTF-8";
      #LC_TIME = "de_DE.UTF-8";
    };
  };
  console = {
    useXkbConfig = true;
    #font = "Lat2-Terminus16";
    #keyMap = "us";
  };

  environment.variables = { EDITOR = "vim"; };
  environment.shellAliases = {
    mnt = "bashmount";
    ll = "ls -lFh";
    la = "ls -alFh";
    sudocode = "sudo -i code --user-data-dir /root/.config/sudocode";
    hdd-sleep = "sudo hdparm -S 1 /dev/disk/by-id/ata-ST1000LM014-1EJ164_W770GLTD";
    doc = "docker-compose";
    ssh-tmp = "ssh -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
    scp-tmp = "scp -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
    nixos-config = "sudocode /etc/nixos/{,{configuration,hardware-configuration}.nix}";
  };

  environment.etc."gitconfig" = {
    mode = "0644";
    text = ''
      [pull]
          ff = only
      [merge]
          ff = false
    '';
    #source = ./git-system-config
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    sddm-kcm # For SDDM settings to appear in KDE settings

    (neovim.override { vimAlias = true; })
    brave
    wget
    parted
    bashmount
    cryptsetup
    git
    delta # Better `git diff`
    gimp
    inkscape
    vscode
    tmux
    btrfs-progs
    nodejs
    rnix-lsp
    # Example: Build vscode with extra dependencies
    #(vscode.overrideAttrs (oldAttrs: {
    #  buildInputs = oldAttrs.buildInputs ++ [ polkit ];
    #}))
    spotify
    docker-compose

    rustup

    # Custom bash-bin defined above
    #zettlr

    anydesk
    appimage-run
    ark
    bc
    birdtray
    borgbackup
    brave
    direnv
    dropbox
    file
    fzf
    glib
    hdparm
    htop
    mariadb-client
    mumble
    ncdu
    nomacs
    octave
    okular
    ack
    pkg-config
    postman
    python3
    glances
    ranger
    restic
    ripgrep
    rustup
    rxvt-unicode
    shellcheck
    thunderbird
    translate-shell
    unzip

    tdesktop # Telegram Desktop

    cifs-utils # For mounting SMB
    gdu
  ];

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

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm = {
    enable = true;
    autoNumlock = true;
    #enableHidpi = true;
  };
  services.xserver.desktopManager.plasma5.enable = true;
  
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  # services.xserver.libinput.touchpad.naturalScrolling = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";
  services.xserver.layout = "eu";
  services.xserver.xkbOptions = "caps:escape";
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 25; # 1000/25 = 40 keys/sec

  # Enable CUPS to print documents.
  services.printing.enable = true;
 
  # Enable Bluetooth
  #hardware.bluetooth.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Update Intel microcode
  hardware.cpu.intel.updateMicrocode = true;

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
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
      text = ''
        mkdir -p /mnt
      '';
      deps = [];
    };
    fixVsCodeWriteAsSudo = {
      # GitHub issue: https://github.com/NixOS/nixpkgs/issues/49643
      text = ''
        mkdir -m 0755 -p /bin
        ln -sf "${pkgs.bash}/bin/bash" /bin/.bash.tmp
        mv /bin/.bash.tmp /bin/bash # atomically replace it
        ln -sf "${pkgs.polkit}/bin/pkexec" /usr/bin/.pkexec.tmp
        mv /usr/bin/.pkexec.tmp /usr/bin/pkexec # atomically replace it
      '';
      deps = [];
    };
  };

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


# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./encryption-configuration.local.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader = {
    timeout = 1;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    # Use the systemd-boot EFI boot loader.
    #systemd-boot.enable = true;
    grub = {
      enable = true;
      version = 2;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = false;
      #configurationLimit = 100;
      memtest86.enable = true;
      backgroundColor = "#000000";
      splashImage = ./res/nixos-boot-background-scaled.png;
      configurationName = "Kirbix";
      # Get gfxmodes from the grub cli with `videoinfo`
      gfxmodeEfi = "1280x1024";
      enableCryptodisk = true;
      extraInitrd = /boot/initrd.keys.gz;
    };
  };

  networking.hostName = "kirbix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp8s0.useDHCP = true;
  networking.interfaces.wlp7s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_COLLATE = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  environment.variables = { EDITOR = "vim"; };
  environment.shellAliases = {
    mnt = "bashmount";
    ll = "ls -lFh";
    la = "ls -alFh";
    sudocode = "sudo code --user-data-dir /root/.config/sudocode";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    (neovim.override { vimAlias = true; })
    brave
    wget
    parted
    bashmount
    cryptsetup
    git
    gimp
    inkscape
    vscode
      tmux
      btrfs-progs
      # Example: Build vscode with extra dependencies
      #(vscode.overrideAttrs (oldAttrs: {
      #  buildInputs = oldAttrs.buildInputs ++ [ polkit ];
      #}))
    ];

    # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "eu";
  services.xserver.xkbOptions = "caps:escape";
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 25; # 1000/25 = 40 keys/sec

  # Enable touchpad support.
  services.xserver.libinput.enable = true;
  services.xserver.libinput.naturalScrolling = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm = {
    enable = true;
    autoNumlock = true;
    enableHidpi = true;
  };
  services.xserver.desktopManager.plasma5.enable = true;

  # Set users to be immutable. This will revert all manual changes to users on system activation.
  #users.mutableUsers = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # (generate hashed passwords with `mkpasswd -m sha512`)
  users.users.root = { hashedPassword = "!"; };
  users.users.x3ro = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "networkmanager"
    ];
    initialHashedPassword = "$6$/0TqsMFIYp1w$X87E80x0hegDCshjhk/98GrW.IN22blu6xXAOQYg5761ATZR/LHWdmFtwH35mvP5Z0KNpkU6hYjsLeUEo7N0v1";
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
        # HACK: Get path dynamically from
        ln -sf "/run/current-system/sw/bin/bash" /bin/.bash.tmp
        mv /bin/.bash.tmp /bin/bash # atomically replace it
        # HACK: Get path dynamically from
        ln -sf "/run/wrappers/bin/pkexec" /usr/bin/.pkexec.tmp
        mv /usr/bin/.pkexec.tmp /usr/bin/pkexec # atomically replace it
      '';
      deps = [];
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}


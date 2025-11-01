# Configuration for workstations (desktops / laptops)
{
  config,
  pkgs,
  lib,
  myLib,
  ...
}: let
  baseconfig = {allowUnfree = true;};
  stable = let
    result = builtins.tryEval (import <nixos-stable>);
  in
    (
      if result.success
      then result.value
      else import <nixos>
    ) {config = baseconfig;};
  #pinned-for-virtualbox = builtins.fetchTarball {
  #    #name = "nixos-pinned-for-virtualbox";
  #    url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/21.11.tar.gz";
  #    sha256 = "162dywda2dvfj1248afxc45kcrg83appjd0nmdb541hl7rnncf02";
  #};
in rec {
  disabledModules = [
    #"virtualisation/virtualbox-host.nix"
  ];
  imports =
    [
      #../modules/nixos-rebuild-wrapper.nix
      ../modules/ios-usb.nix
      ../modules/steam.nix
      ../modules/lutris.nix
    ]
    ++ [
      # Overridden Modules
      #"${pinned-for-virtualbox}/nixos/modules/virtualisation/virtualbox-host.nix"
    ];
  system.extraSystemBuilderCmds = myLib.createCopyExtraConfigFilesScript imports;

  # Enable Flakes
  nix = {
    package = pkgs.nixVersions.stable;

    extraOptions = ''
      # For nix-direnv
      keep-outputs = true
      keep-derivations = true
    '';
  };

  nixpkgs.config =
    baseconfig
    // {
      permittedInsecurePackages = [
        #"electron-25.9.0" # For `obsidian` / `super-productivity`
        "mbedtls-2.28.10" # For openrgb
      ];
      # NOTE: This also replaces the packages when they are used as dependency
      #       for other packages
      packageOverrides = pkgs: {
        #inherit pkgs.unstable;
        #gdu = pkgs.unstable.gdu;
      };
    };

  boot.loader = {
    timeout = 1;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    grub =
      {
        enable = true;
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
      }
      // (
        if (myLib.nixosMinVersion "23.05")
        then {
          # `boot.loader.grub.version` does not have any effect anymore
        }
        else {
          # >= 23.05
          version = 2;
        }
      );
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      # Custom derivations
    ]
    ++ [
      #alacritty
      #autokey
      #bc # Replaced by qalc
      #borgbackup
      #dropbox # Replaced with SyncThing
      #ferdi # TODO: Before uncomment, check if CVE-2022-32320 still applies
      #nox # Broken?
      #parted
      #texlive.combined.scheme-full
      #trilium-desktop # Replaced with Obsidian
      #vlc

      # burpsuite # Builds chromium???

      ack # Alternative grep "for sourcecode"
      anydesk
      appimage-run
      arandr
      kdePackages.ark # KDE archive gui (.tar.gz, etc.)
      audacious
      audacity
      barrier
      bashmount
      birdtray
      blanket # Ambient sounds
      brave
      broot
      btop
      copyq
      cryptsetup
      dbeaver-bin
      delta # Better `git diff`
      deno
      direnv
      discord
      element-desktop
      entr
      escrotum
      ethtool
      exfat
      feh
      #ferdi # TODO: Before uncomment, check if CVE-2022-32320 still applies
      ffmpeg
      file
      filezilla
      firefox
      fzf
      gimp
      gitFull # Enable full-featured git (needed e.g. for `gitk`)
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
      kitty
      #kopia
      ksnip
      libnotify
      libqalculate # qalc
      libreoffice
      linux-wifi-hotspot
      lshw
      mariadb-client
      minio-client
      mpc-qt
      mtr # Better traceroute
      mumble
      ncdu # Replaced with gdu
      nix-direnv
      nodePackages.pnpm
      nodePackages.zx
      nodejs
      nomacs # Image viewer
      nushell
      obs-studio
      #obsidian
      octave
      kdePackages.okular # PDF viewer
      pciutils
      pdfmixtool
      playerctl # Control media players from cli
      polybarFull
      #postman # TODO: Postman is frequently broken because they remove older builds and only keep the latest version online -> bad for NixOS. See https://github.com/NixOS/nixpkgs/issues/259147
      pv
      python3Packages.bpython # Alternative python repl
      quickemu
      ranger
      restic
      rofi
      rofimoji
      rxvt-unicode
      shellcheck
      signal-desktop
      spotify
      sshfs-fuse
      #super-productivity
      syncthing
      syncthingtray
      teamspeak_client
      #thunderbird # Installed through home-manager
      #thunderbird-bin # Installed through home-manager
      tmate
      tor
      tor-browser-bundle-bin
      translate-shell
      tree
      ueberzug # To show images in ranger (not necessary for Kitty)
      unrar
      unzip
      usbutils
      #ventoy-bin # NOTE: Disabled due to security concerns: Ventoy uses binary blobs which can't be trusted to be free of malware or compliant to their licenses. See https://github.com/NixOS/nixpkgs/issues/404663
      virt-manager
      virt-viewer
      virtiofsd # HOTFIX: Required by virt-manager: "ERROR: virtiofsd not executable"
      vscode
      wally-cli # Mechanical keyboard flashing tool
      wireshark-qt
      xclip
      xdotool
      xorg.xev
      xorg.xhost
      xournalpp
      xxd
      yadm
      yt-dlp # Successor of youtube-dl
      zip
    ];

  fonts = let
    packages = with pkgs; [
      font-awesome
    ];
  in
    if (myLib.nixosMinVersion "23.11")
    then {
      inherit packages;
    }
    else {
      fonts = packages;
    };

  environment.shellAliases = {
    mnt = "bashmount";
    doc = "docker compose";
    sudocode = "sudo -i code --no-sandbox --user-data-dir /root/.config/sudocode";
    nixos-config = "sudocode /etc/nixos/{,{configuration,hardware-configuration}.nix}";
  };

  boot.supportedFilesystems = ["ntfs" "ntfs-3g"];

  console = {
    useXkbConfig = true;
    #font = "Lat2-Terminus16";
    #keyMap = "us";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = lib.mkDefault true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = {
    enable = true;
    mouse = {
      accelProfile = "flat";
      middleEmulation = false; # Disable middle mouse button emulation
    };
    touchpad = {
      naturalScrolling = true;
      tappingDragLock = false;
    };
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "eu";
  #services.xserver.xkbOptions = "caps:escape";
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 25; # 1000/25 = 40 keys/sec

  # Enable udev rules for ZSA keyboards (Moonlander)
  hardware.keyboard.zsa.enable = true;

  # Enable support for Wooting keyboards
  hardware.wooting.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.ssh.startAgent = true;

  programs.dconf.enable = true;

  programs.kdeconnect.enable = true;

  programs.nm-applet.enable = lib.mkDefault true; # TODO: Maybe this should go into the desktop-specific config files? It conflicts with the config for Jehuty that has to disable it.

  # List services that you want to enable:

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [gutenprint cnijfilter2];

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
      HandlePowerKey=suspend
      HandleSuspendKey=suspend
      HandleHibernateKey=hibernate
      HandleRebootKey=reboot
    '';
  };

  # TODO: Find out how to set up ananicy so that it does not change niceness of other processes
  #services.ananicy = {
  #    enable = true;
  #    package = pkgs.ananicy-cpp;
  #    extraRules = ''
  #        { "name": "kopia", "nice": 19, "ionice": 7 }
  #        { "name": "kopia-ui", "nice": 19, "ionice": 7 }
  #    '';
  #};

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

  virtualisation.libvirtd.enable = true;
  #virtualisation.virtualbox.host = {
  #    enable = true;
  #    enableExtensionPack = true;
  #    package = pinned-for-virtualbox.pkgs.virtualbox;
  #};

  services.udev.extraRules = ''
    # Enable NumLock on keyboard connect
        # NOTE: It seems to be a udev rule that turns off the numpad state
        #       after a keyboard is connected.  This rule tries to
        #       counterack this but at the cost of introducing a delay when
        #       a device is connected. Since (some?) udev rules are executed
        #       in serial (or devices are connected in serial?), the sleep
        #       causes some delay if a device like a keyboard connects as
        #       multiple devices.
        #
        # NOTE: This seems to be fixed now
        #
        # WARNING: When enabling this rule, the system can't  boot up
        #          because the disks can't be found. I guess this is due to
        #          this rule failing at boot since the user `x3ro` is not
        #          yet available until the disks are mounted.
        #
        #ACTION=="add",
        #SUBSYSTEM=="usb", # maybe "input"?
        #ENV{XAUTHORITY}="/home/x3ro/.Xauthority",
        #ENV{DISPLAY}=":0",
        #ATTRS{product}=="USB Keyboard",
        #RUN+="${pkgs.su}/bin/su x3ro -c '${pkgs.coreutils}/bin/sleep 0.1; [ -f $XAUTHORITY ] && ${pkgs.numlockx}/bin/numlockx on'"
  '';

  # Flatpak
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;

    # HACK: The `xdg-desktop-portal-gtk` is necessary to let flatpak apps
    #       know the system theme. However, gnome comes with its own
    #       version of the portal, which collides with this one. Therefore,
    #       the portal is only added when gnome is not enabled.
    extraPortals = lib.optionals (!config.services.xserver.desktopManager.gnome.enable) (with pkgs; [
      xdg-desktop-portal-gtk # Required for flatpak
    ]);
  };

  # Symlink current rofi themes to /etc
  environment.etc."rofi/themes".source = "${pkgs.rofi}/share/rofi/themes";

  # Allow passing USB devices into VMs through Spice
  virtualisation.spiceUSBRedirection.enable = true;
}

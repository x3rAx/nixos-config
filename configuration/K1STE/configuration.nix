# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  myLib,
  hostname,
  ...
}: rec {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./hardware-override.nix
    ./openrgb.nix
    ./wireguard.nix

    ../../roles/common.nix
    ../../roles/mostly-common.nix
    ../../roles/desktop.nix
    ../../roles/desktop-bspwm.nix
    ../../roles/nvidia.nix
    ../../modules/sunshine.nix
  ];

  # Copies `configuration.nix` and links it from the resulting system to
  # `/run/current-system/configuration.nix`
  #system.copySystemConfiguration = true;
  # !!! DO NOT DO THIS --> # myLib.createCopyExtraConfigFilesScript [ ./. ] !!!
  system.extraSystemBuilderCmds = myLib.createCopyExtraConfigFilesScript imports;

  security.rtkit.enable = true;
  services.pipewire =
    {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      jack.enable = true;
    }
    // (
      if myLib.nixosMinVersion "23.05"
      then {
        # NOTE: Overriding default Pipewire configuration through NixOS
        #       options never worked correctly and is no longer supported.
        #       Please create drop-in files in
        #       /etc/pipewire/pipewire.conf.d/ to make the desired setting
        #       changes instead.
      }
      else {
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

  hardware.xpadneo.enable = true; # For Xbox controller

  hardware.bluetooth.enable = true; # For Bluetooth
  services.blueman.enable = true; # Bluetooth UI

  # Use the X configuration provided by the nvidia-settings tool
  #services.xserver.config = lib.mkAfter (builtins.readFile ./xserver-nvidia.conf);
  # For diagnostics, symlink the config to `/etc/X11/xorg.conf`
  services.xserver.exportConfiguration = true;

  networking.firewall = {
    #allowedUDPPorts = [ 51821 35408 ];
    allowedTCPPorts = [
      24800 # barrier - mouse / keyboard sharing server
    ];
  };

  services.teamviewer.enable = true;

  services.gnome.gnome-keyring.enable = true; # Enable gnome-keyring
  programs.seahorse.enable = true; # GUI for managing keyring
  programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.ksshaskpass.out}/bin/ksshaskpass"; # Use KDE askpass programm since the default X11 program is weird ^^'

  security.pam.services.gdm.enableGnomeKeyring = true; # TODO: Is this necessary when not using GDM?

  # Original:
  # ```
  # $ ulimit -u
  # 127646
  #
  # $ ulimit -Hu
  # 127646
  # ```
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "hard";
      item = "nproc";
      value = "127648"; # Increase by 2 from original value to make arch distrobox container work again
    }
  ];

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
    #"fs.file-max" = 16777216; # For StarCitizen # However, it is now set to the largest possible value by default when using systemd (see `cat /proc/sys/fs/file-max` and https://github.com/systemd/systemd/commit/a8b627aaed409a15260c25988970c795bf963812)
  };

  networking.hostName = hostname; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  programs.gamemode.enable = true;
  programs.corectrl.enable = true;

  programs.zsh.enable = true;

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
    #rnix-lsp # TODO: Remove or re-enable: Depends on `nix-2.15.3` which is marked as insecure due to CVE-2024-27297 (See: https://discourse.nixos.org/t/nixos-need-help-finding-out-what-is-pulling-in-nix-2-15-3-in-my-config/41103/2)

    wineWowPackages.stable
    winetricks
  ];

  systemd.services.systemd-udevd.restartIfChanged = false; # TODO: Remove when https://github.com/NixOS/nixpkgs/issues/180175 is fixed
  #systemd.services.NetworkManager-wait-online.enable = lib.mkForce false; # TODO: Remove when https://github.com/NixOS/nixpkgs/issues/180175 is fixed
  #systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false; # TODO: Remove when https://github.com/NixOS/nixpkgs/issues/180175 is fixed

  # XSecureLock
  environment.etc."systemd/system-sleep/xsecurelock".source = pkgs.writeShellScript "xsecurelock" ''
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
  #virtualisation.docker.enableNvidia = true; # Deprecated
  hardware.nvidia-container-toolkit.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # (generate hashed passwords with `mkpasswd -m sha512`)
  users.users.root = {hashedPassword = "!";};
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
      "openrazer"
      "corectrl" # Control CPU / GPU profiles
    ];
    initialPassword = "changeMe!";
  };

  nix.settings.trusted-users = [config.users.users."x3ro".name];

  programs.nix-ld.enable = true;

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

  services.wyoming.piper.servers."EN_Ryan" = {
    enable = true;
    uri = "tcp://127.0.0.1:10200";
    voice = "en-us-ryan-medium";
  };
}

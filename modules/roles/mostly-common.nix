# Stuff that currently should be on all machines but has the potentil to be
# specific to only some machines in the future
{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: let
  cfg = config.x3ro.roles.mostly-common;
in {
  options = {
    x3ro.roles.mostly-common = {
      enable = lib.mkEnableOption "Enable Module";
    };
  };

  config = lib.mkIf cfg.enable {
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      age
      bat
      bc
      binutils
      broot
      btop
      btrfs-progs
      curlie
      delta
      deno
      diffutils
      distrobox
      #docker-compose # Deprecated
      entr
      expect
      fd
      file
      fzf
      git-filter-repo
      gitui
      glances
      iotop-c
      nfs-utils
      grc
      httpie
      inetutils
      jq
      #kopia
      lsd
      lshw
      ncdu
      neofetch
      nh
      nmap
      nushell
      pv
      python3
      ranger
      ripgrep-all
      trash-cli
      tree
      unzip
      #ventoy-bin # NOTE: Disabled due to security concerns: Ventoy uses binary blobs which can't be trusted to be free of malware or compliant to their licenses. See https://github.com/NixOS/nixpkgs/issues/404663
      wireguard-tools
      xxd

      netavark # Fix Podman error: `Error: could not find "netavark" in one of [/usr/local/libexec/podman /usr/local/lib/podman /usr/libexec/podman /usr/lib/podman].  To resolve this error, set the helper_binaries_dir key in the `[engine]` section of containers.conf to the directory containing your helper binaries.`
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
      defaultLocale = "en_US.UTF-8"; # TODO: If you encounter issues, consider switching to Ireland: "en_IE.UTF-8"
      extraLocaleSettings = {
        # LANG is set by `i18n.defaultLocale`
        # LC_ALL = (unset)

        #LC_CTYPE = "en_US.UTF-8";
        #LC_NUMERIC = "de_DE.UTF-8";
        LC_TIME = "de_DE.UTF-8";
        LC_COLLATE = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        #LC_MESSAGES = "en_US.UTF-8";
        #LC_PAPER = "en_US.UTF-8";
        #LC_NAME = "en_US.UTF-8";
        #LC_ADDRESS = "en_US.UTF-8";
        #LC_TELEPHONE = "en_US.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        #LC_IDENTIFICATION = "en_US.UTF-8";
      };
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
    services.openssh =
      {
        enable = true;
        extraConfig = ''
          Match Address 127.0.0.1,::1
              PermitRootLogin prohibit-password
        '';
      }
      // (
        let
          settings = {
            PasswordAuthentication = false;
            PermitRootLogin = "prohibit-password";
          };
        in
          if myLib.nixosMinVersion "23.05"
          then {
            inherit settings;
          }
          else {
            passwordAuthentication = settings.PasswordAuthentication;
            permitRootLogin = settings.PermitRootLogin;
          }
      );

    services.tailscale = {
      enable = true;
      package = pkgs.unstable.tailscale;
    };

    virtualisation.docker.enable = true;
    virtualisation.docker.package = pkgs.unstable.docker;

    boot.enableContainers = false;
    virtualisation = {
      podman =
        {
          enable = true;

          # Create a `docker` alias for podman, to use it as a drop-in replacement
          #dockerCompat = true;
        }
        // (
          let
            # Required for containers under podman-compose to be able to talk to each other.
            dns_enabled = true;
          in
            if myLib.nixosMinVersion "23.05"
            then {
              defaultNetwork.settings.dns_enabled = dns_enabled;
            }
            else {
              defaultNetwork.dnsname.enable = dns_enabled;
            }
        );
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
  };
}

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  myLib,
  ...
}: let
  importIfExists = path: lib.optional (builtins.pathExists path) path;
in rec {
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./hardware-overrides.nix
      ./rfkill-powerDown.nix

      ../../roles/common.nix
      ../../roles/mostly-common.nix
      ../../roles/desktop.nix
      ../../roles/desktop-kde.nix
      ../../roles/nvidia.nix
    ]
    ++ importIfExists ./local-configuration.nix;

  # TODO: system.nixos.label

  # Copys `configuration.nix` and links it from the resulting system to `/run/current-system/configuration.nix`
  system.copySystemConfiguration = true;
  # !!! DO NOT DO THIS --> # myLib.createCopyExtraConfigFilesScript [ ./. ] !!!
  system.systemBuilderCommands = myLib.createCopyExtraConfigFilesScript imports;

  boot.loader = {
    grub = {
      configurationName = "Kirbix";
    };
  };

  boot.supportedFilesystems = ["ntfs-3g"];

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

  powerManagement.cpuFreqGovernor = "performance";

  networking.hostName = "kirbix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp8s0.useDHCP = true;
  networking.interfaces.wlp7s0.useDHCP = true;

  networking.hosts = {
    #"127.0.0.1" = [ "myapp.local" ];
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  environment.shellAliases = {
    hdd-sleep = "sudo hdparm -S 1 /dev/disk/by-id/ata-ST1000LM014-1EJ164_W770GLTD";
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
    #rnix-lsp # TODO: Remove or re-enable: Depends on `nix-2.15.3` which is marked as insecure due to CVE-2024-27297 (See: https://discourse.nixos.org/t/nixos-need-help-finding-out-what-is-pulling-in-nix-2-15-3-in-my-config/41103/2)
  ];

  programs.ssh.startAgent = true;

  # Enable Bluetooth
  hardware.bluetooth.enable = true;

  services.xserver.xkbOptions = "caps:escape";

  # Use systemd-resolved for DNS
  services.resolved.enable = true;

  # Set users to be immutable. This will revert all manual changes to users on system activation.
  #users.mutableUsers = false;

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
    ];
    initialPassword = "changeMe!";
  };

  #nix.distributedBuilds = true;
  #nix.buildMachines = [ {
  #  hostName = "nix-builder";
  #  system = "x86_64-linux";
  #  # if the builder supports building for multiple architectures,
  #  # replace the previous line by, e.g.,
  #  # systems = ["x86_64-linux" "aarch64-linux"];
  #  maxJobs = 1;
  #  speedFactor = 2;
  #  supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
  #  mandatoryFeatures = [ ];
  #}] ;

  # optional, useful when the builder has a faster internet connection than yours
  #nix.extraOptions = ''
  #  builders-use-substitutes = true
  #'';

  #nix.gc = {
  #  automatic = true;
  #  dates = "weekly";
  #  options = "--delete-older-than 30d";
  #}

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  #
  # When do I update `stateVersion`:
  #   https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  #system.stateVersion = "20.03"; # Did you read the comment?
  system.stateVersion = "22.05"; # Did you read the comment?
}

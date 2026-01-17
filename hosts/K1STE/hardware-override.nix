# This comment enables syntax highlighting in nvim 🤪
{
  pkgs,
  lib,
  myLib,
  ...
}: let
  ssd_options = [
    "defaults"
    "ssd"
    "noatime"
    "discard=async" # TODO: According to Anselm, this is better than "discard". Is this true?
    "noautodefrag" # TODO: Might cause freezes? I had no freezes when this was on "autodefrag". But "autodefrag" is bad for SSDs.
    #"autodefrag" # TODO: This is bad for SSDs but it's a test to see if the freezes go away
  ];
in rec {
  imports = [
    ../../modules/x3ro/btrfs-swapfile.nix
  ];
  system.systemBuilderCommands = myLib.createCopyExtraConfigFilesScript imports;

  x3ro = {
    btrfs-swapfile = {
      enable = true;
      location = "/swap/SWAPFILE";
      hibernation = {
        enable = true;
        resume_device = "/dev/mapper/fsroot_crypt"; # This is new, is this correct?
        resume_offset = 52700416;
      };
    };
  };

  services.fstrim.enable = true;

  #boot.initrd.availableKernelModules = [
  #    "xhci_pci" "ehci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"
  #    #"delayacct" # For `iotop` to display `SWAPIN` and `IO %` (but seems to be unavailable in NixOS)
  #];

  boot.initrd.luks.devices."fsroot_crypt" = {
    allowDiscards = true; # SSD (Potential security risk: https://wiki.archlinux.org/title/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD) )
    bypassWorkqueues = true; # Improve SSD performance
    keyFile = "/crypto_keyfile.bin";
    preLVM = true;
  };
  fileSystems."/".options = ssd_options;

  boot.initrd.luks.devices."secondary_crypt" = {
    allowDiscards = true; # SSD (Potential security risk: https://wiki.archlinux.org/title/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD) )
    bypassWorkqueues = true; # Improve SSD performance
    keyFile = "/crypto_keyfile.bin";
    preLVM = true;
  };
  fileSystems."/home".options = ssd_options;

  # Data mount
  #fileSystems."/storage/data" = {
  #    # NOTE: The `encryped` option does not have an option for
  #    #       `allowDiscards` and `bypassWorkqueues` so I can't use it. I'm
  #    #       using `boot.initrd.luks.devices.<name>` instead.
  #    encrypted = {
  #        enable = true;
  #        label = "data_crypt";
  #        blkDev = "/dev/disk/by-uuid/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"; # UUID for encrypted disk
  #        # NOTE: At the time this keyfile is accessed, the neededForBoot
  #        #       filesystems (see fileSystems.<name?>.neededForBoot) will
  #        #       have been mounted under /mnt-root, so the keyfile path
  #        #       should usually start with "/mnt-root/".
  #        keyFile = "/mnt-root/etc/secrets/initrd/crypto_keyfile.bin";
  #    };
  #};
  boot.initrd.luks.devices."data_crypt" = {
    allowDiscards = true; # SSD (Potential security risk: https://wiki.archlinux.org/title/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD) )
    bypassWorkqueues = true; # Improve SSD performance
    #    device = "/dev/disk/by-uuid/778b63a3-cc84-45ef-8a58-dfe8c858f37c"; # UUID for encrypted disk
    keyFile = "/crypto_keyfile.bin";
  };
  fileSystems."/data/data".options = ssd_options;

  #environment.systemPackages = [ pkgs.cifs-utils ];
  #fileSystems."/data/NAS/^x3ro" = {
  #    device = "//NAS/^x3ro";
  #    fsType = "cifs";
  #    options = let
  #        # this line prevents hanging on network split
  #        automount_opts = "_netdev,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

  #    in ["${automount_opts},credentials=/etc/secrets/samba/x3ro@NAS"];
  #};

  powerManagement.cpuFreqGovernor = lib.mkForce null; # "ondemand", "powersave", "performance"
}

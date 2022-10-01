# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "sd_mod" "rtsx_usb_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/c6236c49-3465-4de2-9208-4432b27cf3a9";
      fsType = "btrfs";
      options = [ "subvol=NixOS/@" ];
    };

  boot.initrd.luks.devices."rootfs_crypt".device = "/dev/disk/by-uuid/a39302ef-abb4-464e-8fa1-fc332f8102e0";

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/E881-1C4F";
      fsType = "vfat";
    };

  fileSystems."/etc/nixos" =
    { device = "/dev/disk/by-uuid/c6236c49-3465-4de2-9208-4432b27cf3a9";
      fsType = "btrfs";
      options = [ "subvol=NixOS/@etc@nixos" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/c6236c49-3465-4de2-9208-4432b27cf3a9";
      fsType = "btrfs";
      options = [ "subvol=NixOS/@home" ];
    };

  fileSystems."/swap" =
    { device = "/dev/disk/by-uuid/c6236c49-3465-4de2-9208-4432b27cf3a9";
      fsType = "btrfs";
      options = [ "subvol=NixOS/@swap" ];
    };

  fileSystems."/var/lib/docker/btrfs" =
    { device = "/swap/NixOS/@home/NixOS/@/var/lib/docker/btrfs";
      fsType = "none";
      options = [ "bind" ];
    };

  fileSystems."/data" =
    { device = "/dev/disk/by-uuid/7a6602b8-3573-453f-b028-81f320807fd5";
      fsType = "btrfs";
      options = [ "subvol=@data" ];
    };

  #boot.initrd.luks.devices."hdd_crypt".device = "/dev/disk/by-uuid/25a0ebf8-1961-40e9-84a5-e92a6de13ccd";

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.docker0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp8s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp7s0.useDHCP = lib.mkDefault true;

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}

# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/dfa39452-8b32-4fdf-a548-2af6f0fc3178";
    fsType = "btrfs";
    options = ["subvol=NixOS/@"];
  };

  boot.initrd.luks.devices."fsroot_crypt".device = "/dev/disk/by-uuid/78506b62-7474-4a17-865e-19584d6e0817";

  fileSystems."/etc/nixos" = {
    device = "/dev/disk/by-uuid/dfa39452-8b32-4fdf-a548-2af6f0fc3178";
    fsType = "btrfs";
    options = ["subvol=NixOS/@etc@nixos"];
  };

  fileSystems."/etc/secrets" = {
    device = "/dev/disk/by-uuid/dfa39452-8b32-4fdf-a548-2af6f0fc3178";
    fsType = "btrfs";
    options = ["subvol=NixOS/@etc@secrets"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/dfa39452-8b32-4fdf-a548-2af6f0fc3178";
    fsType = "btrfs";
    options = ["subvol=NixOS/@home"];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/dfa39452-8b32-4fdf-a548-2af6f0fc3178";
    fsType = "btrfs";
    options = ["subvol=NixOS/@swap"];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/2DFE-0F1A";
    fsType = "vfat";
  };

  fileSystems."/data/data" = {
    device = "/dev/disk/by-uuid/2be26bea-2c86-46ce-9882-654be0f7c65d";
    fsType = "btrfs";
  };

  boot.initrd.luks.devices."data_crypt".device = "/dev/disk/by-uuid/778b63a3-cc84-45ef-8a58-dfe8c858f37c";

  swapDevices = [];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;

  #networking.interfaces.enp4s0.wakeOnLan.enable = true;
  systemd.network.links."50-lan" = {
    matchConfig = {
      MACAddress = "9c:6b:00:05:8f:c0";
    };
    linkConfig = {
      WakeOnLan = "magic";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

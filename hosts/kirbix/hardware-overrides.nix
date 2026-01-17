{myLib, ...}: rec {
  x3ro = {
    btrfs-swapfile = {
      enable = true;
      location = "/swap/SWAPFILE";
      hibernation = {
        enable = true;
        resume_device = "/dev/mapper/rootfs_crypt";
        resume_offset = 23674789;
      };
    };

    services.hdd-sleep = {
      enable = true;
      device = "/dev/disk/by-id/ata-ST1000LM014-1EJ164_W770GLTD";
      timeout-level = 12; # 12 = 60 seconds
    };
  };

  boot.initrd.luks.devices = {
    "rootfs_crypt" = {
      keyFile = "/crypto_keyfile.bin";
      preLVM = true;
      #allowDiscards = true;
    };
  };

  # Data mount
  fileSystems."/data" = {
    encrypted = {
      enable = true;
      label = "hdd_crypt";
      blkDev = "/dev/disk/by-uuid/25a0ebf8-1961-40e9-84a5-e92a6de13ccd"; # UUID for encrypted disk
      keyFile = "/crypto_keyfile.bin";
    };
  };
}

{myLib, ...}: rec {
  imports = [
    ../../modules/x3ro/btrfs-swapfile.nix
  ];
  system.systemBuilderCommands = myLib.createCopyExtraConfigFilesScript imports;

  boot.initrd.luks.devices = {
    "fsroot_crypt" = {
      keyFile = "/luks-fsroot.key";
      preLVM = true;
      #allowDiscards = true;
    };
  };

  x3ro.btrfs-swapfile = {
    enable = true;
    location = "/swap/SWAPFILE";
    hibernation = {
      enable = true;
      resume_device = "/dev/mapper/fsroot_crypt";
      resume_offset = 20097461;
    };
  };
}

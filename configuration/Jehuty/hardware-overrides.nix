{ ... }:
{
    imports = [
        ../../modules/x3ro/btrfs-swapfile.nix
    ];

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
            resume_offset = 1895803;
        };
    };
}

{ ... }:
{
    boot.initrd.luks.devices = {
        "rootfs_crypt" = {
            keyFile = "/crypto_keyfile.bin";
            preLVM = true;
            #allowDiscards = true;
        };
        "swap_crypt" = {
            device = "/dev/disk/by-uuid/4af02479-695d-443a-84f4-a50c0bf39b9d";
            keyFile = "/crypto_keyfile.bin";
            preLVM = true;
            #allowDiscards = true;
        };
    };
    boot.resumeDevice = "/dev/mapper/swap_crypt";

    # Data mount
    fileSystems."/data" = {
        encrypted = {
            enable = true;
            label = "hdd_crypt";
            blkDev = "/dev/disk/by-uuid/25a0ebf8-1961-40e9-84a5-e92a6de13ccd"; # UUID for encrypted disk
            keyFile = "/crypto_keyfile.bin";
        };
        # This should maybe be in `hardware-configuration.nix`
        device = "/dev/mapper/hdd_crypt";
        fsType = "btrfs";
        options = [ "subvol=@data" ];
    };


    swapDevices = [
        { device = "/dev/mapper/swap_crypt"; }
        #{ device = "/dev/disk/by-uuid/c0154c0f-1985-45f5-a733-d10254bb3df7";
        #    encrypted = {
        #        enable = true;
        #        label = "swap_crypt";
        #        blkDev = "/dev/disk/by-uuid/4af02479-695d-443a-84f4-a50c0bf39b9d"; # UUID for encrypted disk
        #        keyFile = "/crypto_keyfile.bin";
        #    };
        #}
    ];
}

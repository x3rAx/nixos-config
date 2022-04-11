{ ... }:
{
    imports = [
        (../../modules/x3ro/btrfs-swapfile.nix)
    ];

    boot.initrd.luks.devices = {
        "sda3_crypt" = {
            allowDiscards = true; # SSD (Potential security risk: https://wiki.archlinux.org/title/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD) )
            bypassWorkqueues = true; # Improve SSD performance
            keyFile = "/crypto_keyfile.bin";
            preLVM = true;
            #allowDiscards = true;
        };
    };
    boot.resumeDevice = "/dev/mapper/sda3_crypt";

    # Data mount
    #fileSystems."/data" = {
    #    device = "/dev/mapper/data_crypt";
    #    fsType = "btrfs";
    #    options = [ "subvol=@data" ];
    #    encrypted = {
    #        enable = true;
    #        label = "data_crypt";
    #        blkDev = "/dev/disk/by-uuid/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"; # UUID for encrypted disk
    #        keyFile = "/crypto_keyfile.bin";
    #    };
    #};
    fileSystems."/data/extended" = {
        device = "/dev/mapper/extended_crypt";
        fsType = "btrfs";
        #options = [ "subvol=@data" ];
        #encrypted = {
        #    enable = true;
        #    label = "extended_crypt";
        #    blkDev = "/dev/disk/by-uuid/72709ae5-8e3c-4b99-9e13-b384014c1776"; # UUID for encrypted disk
        #    # NOTE: At the time this keyfile is accessed, the neededForBoot
        #    #       filesystems (see fileSystems.<name?>.neededForBoot) will
        #    #       have been mounted under /mnt-root, so the keyfile path
        #    #       should usually start with "/mnt-root/".
        #    keyFile = "/mnt-root/etc/secrets/initrd/crypto_keyfile.bin";
        #};
    };
    boot.initrd.luks.devices."extended_crypt" = {
        allowDiscards = true; # SSD (Potential security risk: https://wiki.archlinux.org/title/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD) )
        bypassWorkqueues = true; # Improve SSD performance
        device = "/dev/disk/by-uuid/72709ae5-8e3c-4b99-9e13-b384014c1776"; # UUID for encrypted disk
        keyFile = "/crypto_keyfile.bin";
    };

    # Create swapfile (BTRFS, see https://wiki.archlinux.org/title/Btrfs#Swap_file):
    #
    #     truncate -s 0 /swap/swapfile
    #
    # Fix permissions:
    #
    #     chmod 600 /swap/swapfile
    #
    # Disable "Copy on Write" for swapfile:
    #
    #     chattr +C /swap/swapfile
    #
    # Disable compression for swapfile:
    #
    #     btrfs property set /swap/swapfile compression none
    #
    # Fill swapfile
    #
    #     dd if=/dev/zero of=/swap/swapfile bs=1M count=2048 status=progress
    #
    # Get offset for resume:
    #
    #     filefrag -v /swap/swapfile
    #
    # In the column `physical_offset`, use the left value of the first line
    # (the one that ends with "..". In the example below, it is the value
    # `38912` (surrounded by two stars `**`):
    #
    #     Filesystem type is: ef53
    #     File size of /swapfile is 4294967296 (1048576 blocks of 4096 bytes)
    #      ext:     logical_offset:        physical_offset: length:   expected: flags:
    #        0:        0..       0:    **38912..**   38912:      1:            
    #        1:        1..   22527:      38913..     61439:  22527:             unwritten
    #        2:    22528..   53247:     899072..    929791:  30720:      61440: unwritten
    #     ...
    #
    # OPTIONAL:
    #
    #     mkswap /swap/swapfile
    #     swapon /swap/swapfile
    #
    ## https://discourse.nixos.org/t/how-do-i-set-up-a-swap-file/8323/7?u=x3ro
    #systemd.services = {
    #  create-swapfile = {
    #    serviceConfig.Type = "oneshot";
    #    wantedBy = [ "swap-swapfile.swap" ];
    #    script = ''
    #      if [ -e /swap/swapfile ]; then exit; fi
    #      ${pkgs.coreutils}/bin/truncate -s 0 /swap/swapfile
    #      ${pkgs.e2fsprogs}/bin/chattr +C /swap/swapfile
    #      ${pkgs.btrfs-progs}/bin/btrfs property set /swap/swapfile compression none
    #    '';
    #  };
    #};
    x3ro.btrfs-swapfile = {
        enable = true;
        location = "/swap/SWAPFILE";
        hibernation = {
            enable = true;
            resume_offset = 5780096;
        };
    };
}


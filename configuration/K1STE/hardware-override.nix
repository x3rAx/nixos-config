# This comment enables syntax highlighting in nvim 🤪
let
    ssd_options = [
        "defaults"
        "ssd"
        "noatime"
        "discard=async" # TODO: According to Anselm, this is better than "discard". Is this true?
        "noautodefrag" # TODO: Might cause freezes? I had no freezes when this was on "autodefrag". But "autodefrag" is bad for SSDs.
        #"autodefrag" # TODO: This is bad for SSDs but it's a test to see if the freezes go away
    ];
in {
    imports = [
        (../../modules/x3ro/btrfs-swapfile.nix)
    ];

    boot.initrd.luks.devices."fsroot_crypt" = {
        allowDiscards = true; # SSD (Potential security risk: https://wiki.archlinux.org/title/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD) )
        bypassWorkqueues = true; # Improve SSD performance
        keyFile = "/crypto_keyfile.bin";
        preLVM = true;
    };
    fileSystems."/".options = ssd_options;

    # Data mount
    #fileSystems."/data/extended" = {
    #    # NOTE: The `encryped` option does not have an option for
    #    #       `allowDiscards` and `bypassWorkqueues` so I can't use it. I'm
    #    #       using `boot.initrd.luks.devices.<name>` instead.
    #    encrypted = {
    #        enable = true;
    #        label = "extended_crypt";
    #        blkDev = "/dev/disk/by-uuid/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"; # UUID for encrypted disk
    #        # NOTE: At the time this keyfile is accessed, the neededForBoot
    #        #       filesystems (see fileSystems.<name?>.neededForBoot) will
    #        #       have been mounted under /mnt-root, so the keyfile path
    #        #       should usually start with "/mnt-root/".
    #        keyFile = "/mnt-root/etc/secrets/initrd/crypto_keyfile.bin";
    #    };
    #};
    boot.initrd.luks.devices."extended_crypt" = {
        allowDiscards = true; # SSD (Potential security risk: https://wiki.archlinux.org/title/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD) )
        bypassWorkqueues = true; # Improve SSD performance
        device = "/dev/disk/by-uuid/72709ae5-8e3c-4b99-9e13-b384014c1776"; # UUID for encrypted disk
        keyFile = "/crypto_keyfile.bin";
    };
    fileSystems."/data/extended".options = ssd_options;

    x3ro.btrfs-swapfile = {
        enable = true;
        location = "/swap/SWAPFILE";
        hibernation = {
            enable = true;
            resume_device = "/dev/mapper/fsroot_crypt";
            resume_offset = 176981550;
        };
    };
}


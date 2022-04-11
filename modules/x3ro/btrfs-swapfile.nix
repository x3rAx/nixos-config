{ config, pkgs, lib, ... }:

with lib;

let
    cfg = config.x3ro.btrfs-swapfile;
in {
    imports = [];

    options = {
        x3ro.btrfs-swapfile = {

            enable = mkEnableOption "BTRFS swapfile";

            location = mkOption {
                type = types.str;
                example = "/swap/SWAPFILE";

                    #To create the swapfile, either use option
                    #`x3ro.btrfs-swapfile.autoCreate = true;` or create the
                    #swapfile manually as shown below:

                description = ''
                    Location of the SWAPFILE.

                    Create the file as follows (see https://wiki.archlinux.org/title/Btrfs#Swap_file):

                        swapfile='/swap/SWAPFILE'
                        truncate -s 0 "$swapfile"
    
                    Fix permissions:
   
                        chmod 600 "$swapfile"
                   
                    Disable "Copy on Write" for swapfile:
                   
                        chattr +C "$swapfile"
                   
                    Disable compression for swapfile:
                   
                        btrfs property set "$swapfile" compression none
                   
                    Fill swapfile
                   
                        size_MB=2048
                        dd if=/dev/zero of="$swapfile" bs=1M count=2048 status=progress

                    OPTIONAL:
                   
                        mkswap "$swapfile"
                        swapon "$swapfile"
                '';
            };

            size = mkOption {
                type = types.ints.unsigned;
                example = "20 * 1024";
                description = ''
                    The size of the SWAPFILE in MIB
                '';
            };

            hibernation.enable = mkEnableOption "hibernation";

            hibernation.resume_offset = mkOption {
                type = types.ints.unsigned;
                example = 38912;
                description = ''
                    The offset where the SWAPFILE is located on the partition.

                    This is needed to resume from hibernation.

                    To get the offset, follow below instructions:

                    Get the file fragments:
                   
                        filefrag -v "$swapfile"
                   
                    In the column `physical_offset`, use the left value of the first line
                    (the one that ends with "..". In the example below, it is the value
                    `38912` (surrounded by two stars `**`):
                   
                        Filesystem type is: ef53
                        File size of /swap/SWAPFILE is 4294967296 (1048576 blocks of 4096 bytes)
                         ext:     logical_offset:        physical_offset: length:   expected: flags:
                           0:        0..       0:    **38912..**   38912:      1:            
                           1:        1..   22527:      38913..     61439:  22527:             unwritten
                           2:    22528..   53247:     899072..    929791:  30720:      61440: unwritten
                        ...
                '';
            };
                   

                   
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

        };
    };

    config = mkIf cfg.enable {
        boot.kernelParams = if cfg.hibernation.enable
            #then [ "resume=${cfg.loation}" "resume_offset=${toString cfg.hibernation.resume_offset}" ]
            then [ "resume_offset=${toString cfg.hibernation.resume_offset}" ]
            else [];
        swapDevices = [
            { device = cfg.location; size = 20 * 1024; }
        ];
    };
}

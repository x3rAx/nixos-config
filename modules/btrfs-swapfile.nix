{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.x3ro.btrfs-swapfile;
in {
  options = {
    x3ro.btrfs-swapfile = {
      enable = lib.mkEnableOption "BTRFS swapfile";

      location = lib.mkOption {
        type = lib.types.str;
        example = "/swap/SWAPFILE";

        #To create the swapfile, either use option
        #`x3ro.btrfs-swapfile.autoCreate = true;` or create the
        #swapfile manually as shown below:

        description = ''
          Location of the SWAPFILE.

          Create the file as follows (see https://web.archive.org/web/20251222093538/https://btrfs.readthedocs.io/en/latest/ch-swapfile.html).


              # As a rule of thumb, for hibernation use `ceil(RAM + sqrt(RAM))`
              size='2G'
              swapfile='/swap/SWAPFILE'

              btrfs filesystem mkswapfile --size "$size" "$swapfile"

          OPTIONAL:

              swapon "$swapfile"
        '';
      };

      #size = lib.mkOption {
      #    type = lib.types.ints.unsigned;
      #    example = "20 * 1024";
      #    description = ''
      #        The size of the SWAPFILE in MIB
      #    '';
      #};

      hibernation.enable = lib.mkEnableOption "hibernation";

      hibernation.resume_device = lib.mkOption {
        type = lib.types.str;
        example = "/dev/mapper/rootfs_crypt";
        description = ''
          The device that should be used for resume.

          The value is directly passed to `boot.resumeDevice`.
        '';
      };

      hibernation.resume_offset = lib.mkOption {
        type = lib.types.ints.unsigned;
        example = 38912;
        description = ''
          The offset where the SWAPFILE is located on the partition.
          This is needed to resume from hibernation.

          To get the offset, run:

              btrfs inspect-internal map-swapfile -r "$swapfile"

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

  config = lib.mkIf cfg.enable {
    boot = lib.mkIf cfg.hibernation.enable {
      resumeDevice = cfg.hibernation.resume_device;
      kernelParams = ["resume_offset=${toString cfg.hibernation.resume_offset}"];
    };
    swapDevices = [
      {
        device = cfg.location;
        #size = cfg.size;
      }
    ];
  };
}

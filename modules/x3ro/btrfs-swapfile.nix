{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.x3ro.btrfs-swapfile;
in {
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

          > [!note]
          > According to https://forum.endeavouros.com/t/27485/7
          > since mid 2022, disabling compression is not necessary
          > anymore (and the command fails).
          >
          > I'll still leave this here in case I'll need it again
          >
          > > Disable compression for swapfile:
          > >
          > >     btrfs property set "$swapfile" compression none

          Fill swapfile

              # As a rule of thumb, for hibernation use `ceil(RAM + sqrt(RAM))`
              size_MB=$((2 * 1024))
              dd if=/dev/zero of="$swapfile" bs=1M count="$size_MB" status=progress

          OPTIONAL:

              mkswap "$swapfile"
              swapon "$swapfile"
        '';
      };

      #size = mkOption {
      #    type = types.ints.unsigned;
      #    example = "20 * 1024";
      #    description = ''
      #        The size of the SWAPFILE in MIB
      #    '';
      #};

      hibernation.enable = mkEnableOption "hibernation";

      hibernation.resume_device = mkOption {
        type = types.str;
        example = "/dev/mapper/rootfs_crypt";
        description = ''
          The device that should be used for resume.

          The value is directly passed to `boot.resumeDevice`.
        '';
      };

      hibernation.resume_offset = mkOption {
        type = types.ints.unsigned;
        example = 38912;
        description = ''
          The offset where the SWAPFILE is located on the partition.
          This is needed to resume from hibernation.

          To get the offset, follow below instructions:

          Usually, the file fragments could be received by using `filefrag -v "$swapfile"`.
          However, this might result in false offsets on btrfs.
          (See: https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation_into_swap_file_on_Btrfs)
          Instead we compile and use the tool mentioned in the Arch link above:

              tmpdir=$(mktemp -d --tmpdir)
              url='https://raw.githubusercontent.com/osandov/osandov-linux/d03f560dcef705c05c026b896b0447b53aa00546/scripts/btrfs_map_physical.c'
              nix-shell -p wget gcc --run "cd '$tmpdir' && wget '$url' && gcc -O2 -o btrfs_map_physical btrfs_map_physical.c"

          Now run the program to get the file fragments:

              swapfile="/swap/SWAPFILE"
              "$tmpdir/btrfs_map_physical" "$swapfile" | head

          Use the value from the `PHYSICAL OFFSET` column. In the example table below,
          the value is 96971939840. It has been surrounded by two stars (`**`) to make
          it more visible.

              FILE OFFSET     FILE SIZE       EXTENT OFFSET   EXTENT TYPE     LOGICAL SIZE    LOGICAL OFFSET  PHYSICAL SIZE   DEVID   PHYSICAL OFFSET
              0       134217728       0       regular 134217728       96971939840     134217728       1       **96971939840**
              134217728       134217728       0       regular 134217728       97830686720     134217728       1       97830686720
              268435456       134217728       0       regular 134217728       101694009344    134217728       1       101694009344
              ...

          Finally, we use this physical size to calculate the reume offset:
          Use for example `qalc` to calculate the offset:

              $ nix-shell -p libqalculate --run 'qalc 96971939840 / 4096'
              96971939840 / 4096 = 23674790
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
    boot = mkIf cfg.hibernation.enable {
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

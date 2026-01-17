{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.x3ro.services.hdd-sleep;
in {
  options = {
    x3ro.services.hdd-sleep = {
      enable = lib.mkEnableOption "Enable hdd-sleep service";

      device = lib.mkOption {
        type = lib.types.str;
        example = "/dev/disk/by-id/ata-XXXXXXXXXXX-XXXXXX_XXXXXXXX";

        description = ''
          Device file of the HDD to put to sleep. Keep in mind that direct paths like `/dev/sda` may change
          when more than one disk is attached. It's more safe to use the `/dev/disk-by/...` links instead.
        '';
      };

      timeout-level = lib.mkOption {
        type = lib.types.ints.unsigned;
        example = 1;

        description = ''
          Set the timeout level for the HDD to spin down.

          From the `hdparm` manual:

          >  A value of zero means "timeouts are disabled": the device
          >  will  not  automatically  enter standby  mode.   Values
          >  from  1 to 240 specify multiples of 5 seconds, yielding
          >  timeouts from 5 seconds to 20 minutes.  Values from 241 to
          >  251 specify from 1 to 11 units of 30 minutes, yielding
          >  timeouts from  30  minutes to  5.5 hours.  A value of 252
          >  signifies a timeout of 21 minutes. A value of 253 sets a
          >  vendor-defined timeout period between 8 and 12 hours, and
          >  the value 254 is reserved.  255 is interpreted as 21
          >  minutes plus  15  sec‐ onds.  Note that some older drives
          >  may have very different interpretations of these values.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services."hdd-sleep" = {
      # Unit
      description = "Set HDD standby timeout immediately after wake up";
      after = [
        "default.target"
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
      ];
      # Service
      serviceConfig = {
        User = "root";
        Type = "oneshot";
        #ExecStart = ''${pkgs.hdparm}/bin/hdparm -Y "${cfg.device}"'';
        ExecStart = ''${pkgs.hdparm}/bin/hdparm -S ${toString cfg.timeout-level} "${cfg.device}"'';
        TimeoutSec = 0;
        StandardOutput = "syslog";
      };
      # Install
      wantedBy = [
        "default.target"
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
      ];
    };
  };
}

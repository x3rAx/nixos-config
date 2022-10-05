{ pkgs, ... }:

{
  powerManagement = {
    powerDownCommands = ''
      sleep_before_power_down=0
      sleep_after_block=0
      logfile='/var/log/rfkill-blocked-devices.log'

      _log() { echo >>"$logfile" "[$(date -Ins)] $@"; }

      _log "-- START blocking"
      
      devices="''$(${pkgs.utillinux}/bin/rfkill -rno SOFT,DEVICE)"
      _log "devices: $(echo "''$devices" | ${pkgs.gnused}/bin/sed ':a;N;$!ba;s/\n/ | /g')"
      unblocked="''$(echo "''$devices" | ${pkgs.gawk}/bin/awk '/^unblocked/ { print $2 }')"
      _log "unblocked: $(echo "''$unblocked" | ${pkgs.gnused}/bin/sed ':a;N;$!ba;s/\n/ | /g')"
      echo "''$unblocked" >/run/rfkill-blocked-devices
      while read dev; do
        if [[ -z $dev ]]; then continue; fi
        _log "rfkill block device ''${dev}"
        ${pkgs.utillinux}/bin/rfkill -rno DEVICE,ID \
        | ${pkgs.gawk}/bin/awk -v DEV="$dev" '$1 == DEV { print $2 }' \
        | ${pkgs.findutils}/bin/xargs -i ${pkgs.utillinux}/bin/rfkill block '{}';
        _log "DONE: rfkill block device ''${dev}"
        _log "sleep ''${sleep_after_block}"
        sleep ''${sleep_after_block}
        _log "syncing"
        ${pkgs.coreutils}/bin/sync
      done </run/rfkill-blocked-devices
      _log "sleep for ''${sleep_before_power_down} seconds"
      ${pkgs.coreutils}/bin/sleep $sleep_before_power_down
      _log "-- END blocking"
    '';
    powerUpCommands = ''
      logfile='/var/log/rfkill-blocked-devices.log'

      _log() { echo >>"$logfile" "[$(date -Ins)] $@"; }

      _log "-- START unblocking"
      while read dev; do
        if [[ -z $dev ]]; then continue; fi
        _log "rfkill unblock device ''${dev}"
        ${pkgs.utillinux}/bin/rfkill -rno DEVICE,ID \
        | ${pkgs.gawk}/bin/awk -v DEV="$dev" '$1 == DEV { print $2 }' \
        | ${pkgs.findutils}/bin/xargs -i ${pkgs.utillinux}/bin/rfkill unblock '{}';
        _log "DONE: rfkill unblock device ''${dev}"
      done </run/rfkill-blocked-devices
      _log "rm /run/rfkill-blocked-devices"
      rm /run/rfkill-blocked-devices
      _log "-- END unblocking"
    '';
  };
}

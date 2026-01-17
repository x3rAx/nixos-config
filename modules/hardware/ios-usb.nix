# https://nixos.wiki/wiki/IOS
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.x3ro.hardware.ios-usb;
in {
  options = {
    x3ro.hardware.ios-usb = {
      enable = lib.mkEnableOption "Enable iOS USB support";
    };
  };

  config = lib.mkIf cfg.enable {
    # Support iOS USB storage and tethering
    services.usbmuxd.enable = true;

    environment.systemPackages = with pkgs; [
      libimobiledevice
      ifuse # optional, to mount using 'ifuse'
    ];
  };
}

{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.x3ro.hardware.openrgb;
in {
  options = {
    x3ro.hardware.openrgb.enable = lib.mkEnableOption "Enable OpenRGB";
  };

  config = lib.mkIf cfg.enable {
    services.hardware.openrgb.enable = true;

    environment.systemPackages = with pkgs; [
      polychromatic
    ];
  };
}

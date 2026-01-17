{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.x3ro.roles.virtualisation;
in {
  options = {
    x3ro.roles.virtualisation = {
      enable = lib.mkEnableOption "Enable virtualisation with virt-manager and libvirtd";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.virt-manager.enable = true;

    users.groups.libvirtd.members = ["x3ro"];

    virtualisation.libvirtd.enable = true;

    virtualisation.spiceUSBRedirection.enable = true;

    environment.systemPackages = with pkgs; [dnsmasq];
  };
}

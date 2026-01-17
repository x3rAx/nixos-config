# Configuration for servers
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.x3ro.roles.server;
in {
  options = {
    x3ro.roles.server = {
      enable = lib.mkEnableOption "Enable server role";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.shellAliases = {
      doc = "sudo docker compose";
    };

    virtualisation.docker.extraOptions = ''
      --userns-remap=x3ro:users
    '';

    systemd.services.docker-userns-socat = {
      requiredBy = ["docker.service"];
      serviceConfig = {
        ExecStart = ''${pkgs.socat}/bin/socat UNIX-LISTEN:/var/run/docker-userns.sock,user=100000,group=100000,mode=0600,fork UNIX-CLIENT:/var/run/docker.sock'';
      };
    };
  };
}


# Configuration for servers
{ config, pkgs, ... }:

{
    environment.shellAliases = {
        doc = "sudo docker compose";
    };

    virtualisation.docker.extraOptions = ''
        --userns-remap=x3ro:users
    '';

    systemd.services.docker-userns-socat = {
        requiredBy = [ "docker.service" ];
        serviceConfig = {
        ExecStart = ''${pkgs.socat}/bin/socat UNIX-LISTEN:/var/run/docker-userns.sock,user=100000,group=100000,mode=0600,fork UNIX-CLIENT:/var/run/docker.sock'';
        };
    };
}

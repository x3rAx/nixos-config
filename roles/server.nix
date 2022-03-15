
# Configuration for servers
{ config, pkgs, ... }:

{
    environment.shellAliases = {
        doc = "sudo docker-compose";
    };
}

# Configuration for workstations (desktops / laptops)
{ config, pkgs, ... }:

rec {
    services.xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
    };
}



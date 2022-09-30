# Configuration for workstations (desktops / laptops)
{ config, pkgs, ... }:

rec {
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        sddm-kcm # For SDDM settings to appear in KDE settings
    ];

    services.xserver.enable = true;
    # Enable the Plasma 5 Desktop Environment.
    services.xserver.displayManager.sddm = {
        enable = true;
        autoNumlock = true;
        #enableHidpi = true;
    };
    services.xserver.desktopManager.plasma5.enable = true;
}

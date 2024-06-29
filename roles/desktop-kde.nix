# Configuration for workstations (desktops / laptops)
{ config, pkgs, ... }:

rec {
    services.xserver = {
        enable = true;

        displayManager.sddm = {
            enable = true;
            autoNumlock = true;
            #enableHidpi = true;
        };

        desktopManager = {
            plasma5.enable = true;
        };
    };
    services.xserver.desktopManager.plasma5.enable = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        sddm-kcm # For SDDM settings to appear in KDE settings
        ark # KDE archive gui (.tar.gz, etc.)
        plasma-applet-caffeine-plus
        #libsForQt5.krohnkite # Tiling window KWin script (does not work, "settings file not found"?)
    ];

    security.pam.services.kwallet = {
        name = "kwallet";
        enableKwallet = true;
    };
}

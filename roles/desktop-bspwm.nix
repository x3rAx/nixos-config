# Configuration for workstations (desktops / laptops)
{ config, pkgs, ... }:

rec {
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        xtitle # To get window titles from scripts
    ];

    services.xserver = {
        enable = true;

        displayManager = {
            #lightdm = {
            #    enable = true;
            #    background = (myLib.toPath "/home/x3ro/Pictures/[Wallpapers]/1920x1080/tree-on-a-hill.jpg");
            #};

            sddm = {
                enable = true;
                autoNumlock = true;
                #enableHidpi = true;
            };
        };

        desktopManager.xfce = {
            enable = true;
            enableXfwm = false; # Disable default XFCE window manager
            noDesktop = true; # Don’t install XFCE desktop components (xfdesktop and panel).
            enableScreensaver = false; # I will bring my own screensaver, thanks.
        };

        windowManager.bspwm = {
            enable = true;
            #package = "pkgs.bspwm-unstable";
            configFile = "/home/x3ro/.config/bspwm/bspwmrc";
            sxhkd.configFile= "/home/x3ro/.config/sxhkd/sxhkdrc";
        };
    };
}




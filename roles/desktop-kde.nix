# Configuration for workstations (desktops / laptops)
{
  config,
  pkgs,
  ...
}: rec {
  services.xserver = {
    enable = true;

    displayManager.sddm = {
      enable = true;
      autoNumlock = true;
      #enableHidpi = true;
    };
  };
  services.desktopManager = {
    plasma6.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    kdePackages.sddm-kcm # For SDDM settings to appear in KDE settings
    kdePackages.ark # KDE archive gui (.tar.gz, etc.)
    #plasma-applet-caffeine-plus # NOTE: Package not available anymore
    #libsForQt5.krohnkite # Tiling window KWin script (does not work, "settings file not found"?)
    kde-rounded-corners
  ];

  security.pam.services.kwallet = {
    name = "kwallet";
    enableKwallet = true;
  };
}

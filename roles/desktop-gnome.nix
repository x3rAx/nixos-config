# Configuration for workstations (desktops / laptops)
{
  config,
  pkgs,
  ...
}: let
  baseconfig = {allowUnfree = true;};
in rec {
  services.xserver = {
    enable = true;

    displayManager = {
      gdm.enable = true;
    };

    desktopManager = {
      gnome.enable = true;
    };
  };

  environment.systemPackages = with pkgs;
    [
      gnome.gnome-tweaks
      gnome.dconf-editor
    ]
    ++ (with gnomeExtensions; [
      appindicator
      blur-my-shell
      caffeine
      dash-to-dock
      top-panel-workspace-scroll # Alternative extension: panel-workspace-scroll
    ])
    ++ (with pkgs.unstable.gnomeExtensions; [
      pop-shell
    ]);

  services.udev.packages = with pkgs; [
    gnome.gnome-settings-daemon
  ];

  # Enable Gnome browser extension to work
  #services.gnome.chrome-gnome-shell.enable = true;
  #nixpkgs.config.firefox.enableGnomeExtensions = true;
  #services.gnome.core-shell.enable = true;
}

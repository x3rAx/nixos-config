# Configuration for workstations (desktops / laptops)
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.x3ro.roles.desktop.gnome;

  baseconfig = {allowUnfree = true;};
in {
  options = {
    x3ro.roles.desktop.gnome = {
      enable = lib.mkEnableOption "Enable GNOME desktop";
    };
  };

  config = lib.mkIf cfg.enable rec {
    x3ro = {
      roles.desktop.enable = true;
    };

    services.xserver = {
      enable = true;

      displayManager = {
        gdm.enable = true;
      };
    };
    services.desktopManager = {
      gnome.enable = true;
    };

    environment.systemPackages = with pkgs;
      [
        gnome-tweaks
        dconf-editor
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
      gnome-settings-daemon
    ];

    # Do not start the OpenSSH agent agent on login. Gnome already has the GCR SSH agent enabled.
    programs.ssh.startAgent = false;

    # Enable Gnome browser extension to work
    #services.gnome.chrome-gnome-shell.enable = true;
    #nixpkgs.config.firefox.enableGnomeExtensions = true;
    #services.gnome.core-shell.enable = true;
  };
}

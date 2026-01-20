{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: let
  cfg = config.x3ro.programs.lutris;

  overlay-lutris-with-custom-desktop-file = final: prev: {
    lutris-unwrapped = prev.lutris-unwrapped.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          desktop_file="$out/share/applications/net.lutris.Lutris.desktop"
          new_desktop_file="$out/share/applications/net.lutris.Lutris-system.desktop"
          awk '
                  BEGIN { print "# Modified by ^x3ro"}
                  /^\[/ { section = $0 };
                  (section == "[Desktop Entry]") && /^Name=/ {
                      $0 = $0 " (System)"
                  }
                  (section == "[Desktop Entry]") && /^StartupWMClass=/ {
                      $0 = $0 "_System"
                  }
                  1
              ' "$desktop_file" > "''${new_desktop_file}"
        '';
      #});
    });
  };
in {
  options = {
    x3ro.programs.lutris = {
      enable = lib.mkEnableOption "Enable Lutris with custom `.desktop` file";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      overlay-lutris-with-custom-desktop-file
    ];
    environment.systemPackages = with pkgs; [
      lutris
      #(lutris.override {
      #  extraLibraries = pkgs: [
      #    # List library dependencies here
      #  ];
      #  extraPkgs = pkgs: [
      #    # List package dependencies here
      #  ];
      #})
    ];
  };
}

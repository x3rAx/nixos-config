{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: let
  cfg = config.x3ro.programs.steam;

  overlay-steam-with-custom-desktop-file = final: prev: {
    #steamPackages = prev.steamPackages.overrideScope (final: prev: {
    #  steam = prev.steam.overrideAttrs (oldAttrs: {
    #    postInstall =
    #      oldAttrs.postInstall
    #      + ''
    #        awk '
    #                BEGIN { print "# Modified by ^x3ro"}
    #                /^\[/ { section = $0 };
    #                (section == "[Desktop Entry]") && /^Name=/ {
    #                    $0 = $0 " (System)"
    #                }
    #                1
    #            ' $out/share/applications/steam.desktop > $out/share/applications/.steam.desktop
    #        mv $out/share/applications/.steam.desktop $out/share/applications/steam.desktop
    #      '';
    #  });
    #});

    steam-unwrapped-with-custom-desktop-file = prev.steam-unwrapped.overrideAttrs (oldAttrs: {
      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          desktop_file="$out/share/applications/steam.desktop"
          tmp_desktop_file="$out/share/applications/.steam.desktop.tmp"
          awk < $desktop_file '
                  BEGIN { print "# Modified by ^x3ro"}
                  /^\[/ { section = $0 };
                  (section == "[Desktop Entry]") && /^Name=/ {
                      $0 = $0 " (System)"
                  }
                  1
              ' > $tmp_desktop_file
          mv $tmp_desktop_file $desktop_file
        '';
    });
    steam-with-custom-desktop-file = prev.steam.override {
      steam-unwrapped = final.steam-unwrapped-with-custom-desktop-file;
    };
  };
in {
  options = {
    x3ro.programs.steam = {
      enable = lib.mkEnableOption "Enable Steam with custom `.desktop` file";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      overlay-steam-with-custom-desktop-file
    ];

    programs.steam = {
      enable = true;
      package = pkgs.steam-with-custom-desktop-file;
    };
  };
}

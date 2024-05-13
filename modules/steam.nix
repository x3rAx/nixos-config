{ config, pkgs, lib, myLib, ... }:

let
    overlay-steam-with-custom-desktop-file = (final: prev: {
        steamPackages = prev.steamPackages.overrideScope (final: prev: {
            steam = prev.steam.overrideAttrs (oldAttrs: {
                postInstall = oldAttrs.postInstall + ''
                    awk '
                            /^\[/ { section = $0 };
                            (section == "[Desktop Entry]") && /^Name=/ {
                                $0 = $0 " (System)"
                            }
                            1
                        ' $out/share/applications/steam.desktop > $out/share/applications/.steam.desktop
                    mv $out/share/applications/.steam.desktop $out/share/applications/steam.desktop
                '';
            });
        });
    });
in

{
    nixpkgs.overlays = [
        overlay-steam-with-custom-desktop-file
    ];
    programs.steam.enable = true;
}

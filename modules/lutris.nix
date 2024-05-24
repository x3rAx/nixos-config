{
  config,
  pkgs,
  lib,
  myLib,
  ...
}: let
  overlay-lutris-with-custom-desktop-file = final: prev: {
    lutris-unwrapped = prev.lutris-unwrapped.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          desktop_file="$out/share/applications/net.lutris.Lutris.desktop"
          awk '
                  /^\[/ { section = $0 };
                  (section == "[Desktop Entry]") && /^Name=/ {
                      $0 = $0 " (System)"
                  }
                  (section == "[Desktop Entry]") && /^StartupWMClass=/ {
                      $0 = $0 "_System"
                  }
                  1
              ' "$desktop_file" > "''${desktop_file}.tmp"
          mv "''${desktop_file}.tmp" "$desktop_file"
        '';
      #});
    });
  };
in {
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
}

{ config, pkgs, ... }:

let
  nixos-rebuild-wrapper =
    pkgs.writeShellScriptBin "nixos-rebuild" ''
      orig_PWD="$PWD"
      check=false
      if [ $1 == '--force-plz-i-fcked-up' ]; then
          shift
      else
          for arg in "$@"; do
              # Allow only arguments starting with a minus (to support e.g. `--help`) and `dry-*` commands
              if [[ ! "$arg" =~ ^- ]] && [[ ! "$arg" =~ ^dry- ]]; then
                  check=true
              fi
          done
      fi
      if [[ $check == true ]]; then
          nixosConfig="$(echo $NIX_PATH | tr : $'\n' | awk '/^nixos-config=/ { st = index($0, "="); print substr($0, st+1) }')"
          configDir="$(dirname "$nixosConfig")"
          cd "$configDir"
          if ! $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
              # Warn if config is not in a git repository
              echo >&2 -ne "\n $(tput bold; tput setab 226; tput setaf 0)  WARNING  $(tput sgr0) "
              echo >&2 -e "No git repository found in \"''${configDir}\".\n"
          elif [ -n "$(git status --porcelain)" ]; then
              # Fail when dirty
              echo >&2 -ne "\n $(tput bold; tput setab 124; tput setaf 255)  ERROR  $(tput sgr0) "
              echo >&2 -e "Uncommitted changes in \"''${configDir}\". Please commit them first.\n"
              exit 1
          fi
      fi
      cd "$orig_PWD"
      ${pkgs.nixos-rebuild}/bin/nixos-rebuild "$@"
    '';
in {
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        nixos-rebuild-wrapper

        anydesk
        anydesk
        appimage-run
        arandr
        ark # KDE archive gui (.tar.gz, etc.)
        bashmount
        birdtray
        brave
        copyq
        feh
        ferdi
        firefox
        gimp
        htop
        inkscape
        keepassxc
        mpc-qt
        mumble
        nomacs
        obs-studio
        okular
        rofi
        rofimoji
        signal-desktop
        spotify
        super-productivity
        sxhkd
        syncthing
        syncthingtray
        tdesktop # Telegram Desktop
        teamspeak_client
        thunderbird
        tmate
        trilium-desktop
        usbutils
        vscode
        wally-cli # Mechanical keyboard flashing tool
        xclip
        xdotool #desktop
    ];
}

{ lib, config, ... }:

let myLib = {

    # Get the character at the given index of a string
    charAt = i: s: builtins.substring i (i+1) s;

    # Convert a string to a nix path
    toPath = s:
        if myLib.charAt 0 s == "/"
        then /. + s 
        else
            if builtins.substring 0 2 s == "./"
            then ./. + builtins.substring 1 (builtins.stringLength s) s
            else throw "Path must be either absolute (starting with \"/\") or relative (starting with \"./\")"
        ;


    # Copy other files to store and link them to `/run/current-system/`
    createCopyExtraConfigFilesScript = paths:
        let
            newline = ''
            '';
            makeLinkCommand = path:
                let relativePath = builtins.toString path;
                in ''
                    target="''${out}/extra-config-files/$(realpath --canonicalize-missing --relative-base=/etc/nixos "${relativePath}")"
                    mkdir -p "$(dirname "''$target")"
                    ln -s '${path}' "''$target"
                '';
            linkCommands = map makeLinkCommand paths;
        in
            builtins.concatStringsSep newline linkCommands;


    # Check if the current NixOS version is at least the given version
    nixosMinVersion = version:
        (builtins.compareVersions
            config.system.nixos.release
            version
        ) >= 0;


    # Checks if a given path exists and returns either a list with the path as
    # single element or an empyt list if the path does not exist.
    importIfExists = path: lib.optional (builtins.pathExists path) path;
};

in myLib

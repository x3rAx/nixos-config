let
in rec {
    charAt = i: s: builtins.substring i (i+1) s;

    toPath = s:
        if charAt 0 s == "/"
        then /. + s 
        else
            if builtins.substring 0 2 s == "./"
            then ./. + builtins.substring 1 (builtins.stringLength s) s
            else throw "Path must be either absolute (starting with \"/\") or relative (starting with \"./\")"
        ;

    # Copy other files to store and link them to `/run/current-system/`
    createLinkExtraConfigFilesScript = paths:
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
}
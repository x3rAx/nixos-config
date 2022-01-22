let
    charAt = i: s: builtins.substring i (i+1) s;
    toPath = s:
        if charAt 0 s == "/"
        then /. + s 
        else
            if builtins.substring 0 2 s == "./"
            then ./. + builtins.substring 1 (builtins.stringLength s) s
            else throw "Path must be either absolute (starting with \"/\") or relative (starting with \"./\")"
        ;
in {
    inherit charAt;
    inherit toPath;
}
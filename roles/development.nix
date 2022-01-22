{ config, pkgs, ... }:

{
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        delta # Better `git diff`
        direnv
        gitui
        httpie
        jq
        nodejs
        postman
        python3
        rustup
        rustup
        shellcheck
    ];
}

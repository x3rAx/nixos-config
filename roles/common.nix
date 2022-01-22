{ config, pkgs, ... }:

{
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        nix-bash-completions

        (neovim.override { vimAlias = true; })
        bat #common
        fd
        gdu
        git
        killall
        ripgrep #common
        tmux
        wget
    ];
}

# Stuff that really should be on all machines
{ config, pkgs, ... }:

{
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        nix-bash-completions

        (neovim.override { vimAlias = true; })
        bat
        fd
        gdu
        git
        htop
        killall
        ripgrep
        tmux
        wget
    ];

    environment.variables = {
        EDITOR = "vim";
    };

    environment.etc."gitconfig" = {
        mode = "0644";
        text = ''
            [pull]
                ff = only
            [merge]
                ff = false
        '';
        #source = ./git-system-config
    };

    environment.shellAliases = {
        # TODO: EDITOR=${EDITOR:-vim}
        sudo = "\\sudo EDITOR=vim";
        ll = "ls -lFh";
        la = "ls -alFh";
        ssh-tmp = "ssh -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
        scp-tmp = "scp -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
        gdiff = "git diff --no-index \"$@\"";
    };

    # Update Intel microcode
    hardware.cpu.intel.updateMicrocode = true;
}

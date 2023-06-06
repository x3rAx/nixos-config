# Stuff that really should be on all machines
{ config, pkgs, ... }:

{
    imports = [
        ../modules/neovim.nix
    ];

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        nix-bash-completions

        bat
        fd
        gdu
        htop
        killall
        ripgrep
        tmux
        wget
    ];

    programs.git = {
        enable = true;
        lfs.enable = true;
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
        ll = "ls -lFh";
        la = "ls -alFh";
        ssh-tmp = "ssh -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
        scp-tmp = "scp -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
        gdiff = "git diff --no-index \"$@\"";
    };

    # Update Intel microcode
    hardware.cpu.intel.updateMicrocode = true;
}

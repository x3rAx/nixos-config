# Stuff that really should be on all machines
{ config, pkgs, ... }:

let
  neovim-system-config = pkgs.writeTextFile rec{
    name = "neovim-system-config";
    destination = "/etc/xdg/nvim/sysinit.vim";
    text = ''
      " Indent with 4 spaces
          filetype indent on
          set tabstop=4    " show existing tabs with 4 spaces width
          set shiftwidth=4 " when indenting with '>', use 4 spacees width
          set expandtab    " on pressing tab, inssert 4 spaces
          set autoindent
          autocmd FileType yaml set indentkeys-=0#

      " Jump to last position
          autocmd BufReadPost *
              \ if line("'\"") >= 1 && line("'\"") <= line("$") |
              \   exe "normal! g`\"" |
              \ endif

      " Smart case (in)sensitive search
          :set ignorecase
          :set smartcase

      " Scrolloff
          set scrolloff=5
          " When jumping to end of file, leave 5 lines blank below
          nnoremap G 5<C-y>G5<C-e>

      " Improved line shifting
          vnoremap < <gv
          vnoremap > >gv
    '';
  };
in {
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        nix-bash-completions

        (neovim.override { vimAlias = true; })
        neovim-system-config

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
        vimdiff = "nvim -d";
    };

    # Update Intel microcode
    hardware.cpu.intel.updateMicrocode = true;
}

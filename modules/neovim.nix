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
        (neovim.override {
            vimAlias = true;
            viAlias = true;
        })
        neovim-system-config
    ];

    environment.variables = {
        EDITOR = "nvim";
    };

    environment.shellAliases = {
        #sudo = "\\sudo EDITOR=\${EDITOR:-nvim}"; # TODO: This alias breaks kitty integration (bash complains during startup when sourcing the kitty.bash file). But this should not be necessary anyways because `environment.variables.EDITOR` seems to also set this for `sudo`
        vimdiff = "nvim -d";
    };
}

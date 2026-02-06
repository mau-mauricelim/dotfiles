" Vim plug bootstrap
let plug_path = expand('~/.vim/autoload/plug.vim')

if !filereadable(plug_path)
    echo "INFO: Downloading vim-plug"
    execute '!curl -fLo ' . plug_path . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    if v:shell_error != 0
        echoerr "ERROR: Failed to download vim-plug. Check your internet connection."
    endif
endif

if filereadable(plug_path)
    " Make sure you use single quotes
    call plug#begin()
    Plug 'joshdick/onedark.vim'
    Plug 'airblade/vim-gitgutter'
    Plug 'vim-airline/vim-airline'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'tpope/vim-vinegar'
    Plug 'tpope/vim-commentary'
    call plug#end()
endif

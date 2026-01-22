" Vim plug
" Bootstrap
if !isdirectory('~/.vim/autoload/plug.vim')
    call system('curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
endif

" Make sure you use single quotes
call plug#begin()
    Plug 'joshdick/onedark.vim'
    Plug 'airblade/vim-gitgutter'
    Plug 'itchyny/lightline.vim'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
call plug#end()

if exists('g:plugs["onedark.vim"]')
    colorscheme onedark
endif

if exists('g:plugs["lightline.vim"]')
    set laststatus=2
    if exists('g:onedark')
        let g:lightline = {
            \ 'colorscheme': 'onedark',
            \ }
    endif
endif

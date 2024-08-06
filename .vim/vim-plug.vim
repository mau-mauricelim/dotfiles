" Vim plug
" Bootstrap
if !isdirectory('~/.vim/autoload/plug.vim')
    call system('curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
endif

" Make sure you use single quotes
call plug#begin()
    Plug 'airblade/vim-gitgutter'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
call plug#end()

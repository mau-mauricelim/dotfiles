if exists('g:plugs["onedark.vim"]')
    colorscheme onedark
endif

if exists('g:plugs["vim-airline"]')
    let g:airline#extensions#tabline#enabled = 1
endif

if exists('g:plugs["fzf"]') && exists('g:plugs["fzf.vim"]')
    " [S]earch [F]iles
    nnoremap <Leader>sf :Files<CR>
    vnoremap <Leader>sf <Esc>:Files<CR>
    " Grep
    nnoremap <Leader>sg :Rg<CR>
    vnoremap <Leader>sg <Esc>:Rg<CR>
endif

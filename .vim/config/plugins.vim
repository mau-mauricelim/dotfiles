if exists('g:plugs["onedark.vim"]')
    silent! colorscheme onedark
endif

if exists('g:plugs["vim-gitgutter"]')
    nmap ]h <Plug>(GitGutterNextHunk)
    nmap [h <Plug>(GitGutterPrevHunk)
endif

if exists('g:plugs["vim-airline"]')
    let g:airline#extensions#tabline#enabled = 1
    " Hide the default mode indicator at the bottom of the screen as using status line plugin
    set noshowmode
endif

if exists('g:plugs["vim-commentary"]')
    nmap gcn ONOTE: <Esc>gccA
    nmap gct OTODO: <Esc>gccA
endif

if exists('g:plugs["fzf"]') && exists('g:plugs["fzf.vim"]')
    " [S]earch [F]iles
    nnoremap <Leader>sf :Files<CR>
    " [ ] Find existing buffers
    nnoremap <Leader><Leader> :Buffers<CR>
    " Grep
    nnoremap <Leader>sg :Rg<CR>
    " [S]earch Recent Files ("." for repeat)
    nnoremap <Leader>s. :History<CR>
    " [S]earch [C]ommand history
    nnoremap <Leader>sc :History:<CR>
    " Search History
    nnoremap <Leader>s/ :History/<CR>
    " [S]earch [K]eymaps
    nnoremap <Leader>sk :Maps<CR>
    " Visual selection or word
    vnoremap <Leader>sw y:Rg <C-R>"<CR>
endif

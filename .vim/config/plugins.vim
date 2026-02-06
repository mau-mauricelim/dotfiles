if exists('g:plugs["onedark.vim"]')
    colorscheme onedark
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
    vnoremap <Leader>sf <Esc>:Files<CR>
    " [ ] Find existing buffers
    nnoremap <Leader><Leader> :Buffers<CR>
    vnoremap <Leader><Leader> <Esc>:Buffers<CR>
    " Grep
    nnoremap <Leader>sg :Rg<CR>
    vnoremap <Leader>sg <Esc>:Rg<CR>
    " [S]earch Recent Files ("." for repeat)
    nnoremap <Leader>s. :History<CR>
    vnoremap <Leader>s. <Esc>:History<CR>
    "[S]earch [C]ommand history
    nnoremap <Leader>sc :History:<CR>
    vnoremap <Leader>sc <Esc>:History:<CR>
    " Search History
    nnoremap <Leader>s/ :History/<CR>
    vnoremap <Leader>s/ <Esc>:History/<CR>
    " [S]earch [K]eymaps
    nnoremap <Leader>sk :Maps<CR>
    vnoremap <Leader>sk <Esc>:Maps<CR>
endif

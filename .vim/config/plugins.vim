if exists('g:plugs["vim-highlightedyank"]')
    if !exists('##TextYankPost')
        nmap y <Plug>(highlightedyank)
        xmap y <Plug>(highlightedyank)
        omap y <Plug>(highlightedyank)
    endif
    let g:highlightedyank_highlight_duration = 200
endif

if exists('g:plugs["onedark.vim"]')
    silent! colorscheme onedark
endif

if exists('g:plugs["vim-gitgutter"]')
    let g:gitgutter_map_keys = 0
    nmap ]h <Plug>(GitGutterNextHunk)
    nmap [h <Plug>(GitGutterPrevHunk)
    " You cannot unstage a staged hunk with this plugin
    nmap <Leader>hs <Plug>(GitGutterStageHunk)
    nmap <Leader>hr <Plug>(GitGutterUndoHunk)
    nmap <Leader>hp <Plug>(GitGutterPreviewHunk)
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
    " Grep (visual selection)
    nnoremap <Leader>sg :Rg<CR>
    vnoremap <Leader>sg y:Rg <C-r>"<CR>
    " [S]earch Recent Files ("." for repeat)
    nnoremap <Leader>s. :History<CR>
    " [S]earch [C]ommand history
    nnoremap <Leader>sc :History:<CR>
    " Search History
    nnoremap <Leader>s/ :History/<CR>
    " [S]earch [K]eymaps
    nnoremap <Leader>sk :Maps<CR>
    " Visual selection or word
    nnoremap <Leader>sw yiw:Rg <C-r>"<CR>
    vnoremap <Leader>sw y:Rg <C-r>"<CR>
endif

if exists('g:plugs["vim-easy-align"]')
    " NOTE: Instead of finishing the alignment with a delimiter key, you can type in a regular expression if you press <CTRL-/> or <CTRL-X>
    " Start interactive EasyAlign in visual mode (e.g. vipga)
    xmap ga <Plug>(EasyAlign)
    " Start interactive EasyAlign for a motion/text object (e.g. gaip)
    nmap ga <Plug>(EasyAlign)
endif

if exists('g:plugs["vim-exchange"]')
    let g:exchange_no_mappings = 1
    nmap gx <Plug>(Exchange)
    vmap gx <Plug>(Exchange)
    nmap gxc <Plug>(ExchangeClear)
    nmap gxx <Plug>(ExchangeLine)
endif

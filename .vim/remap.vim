" Toggle line number
nnoremap <C-n> :set nonu!<CR>

" Center screen on current line
nnoremap j jzz
nnoremap k kzz
nnoremap G Gzz
nnoremap <C-End> <C-End>zz
nnoremap <Down> jzz
nnoremap <Up> kzz
nnoremap <PageUp> <PageUp>zz
nnoremap <PageDown> <PageDown>zz
nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz

" Remap C-c to Esc
inoremap <C-c> <Esc>
" Visual block mode - suppress the default <C-c>/<C-v> mapping specifically for WSL
nnoremap <leader>v <C-v>

" Delete to end of line and insert
nnoremap <leader>dd ^d$a
" Delete all lines and insert
nnoremap <leader>da ggdGi
" Search and replace the word under the cursor
nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>

" NERDCommenter
" Ctrl+/
map <C-_> <plug>NERDCommenterToggle

" Customizing commands for fzf.vim
command! -bang -nargs=* Rg call fzf#vim#grep("rg --hidden --glob '!.git' --column --line-number --no-heading --color=always --smart-case -- ".fzf#shellescape(<q-args>), fzf#vim#with_preview(), <bang>0)

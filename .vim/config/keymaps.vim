" Redraw / Clear hlsearch / Diff Update on pressing <Esc>
if v:version >= 900
    nnoremap <silent> <Esc> :nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>
else
    " Older vim versions has issue with single Esc key
    nnoremap <silent> <Esc><Esc> :nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>
endif

" Exit terminal mode
tnoremap <Esc><Esc> <C-\><C-n>

" Split navigation with Ctrl-HJKL
nnoremap <C-h> <C-w><C-h>
nnoremap <C-l> <C-w><C-l>
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>

" Side scroll
nnoremap <S-ScrollWheelUp> 10zh
vnoremap <S-ScrollWheelUp> 10zh
nnoremap <S-ScrollWheelDown> 10zl
vnoremap <S-ScrollWheelDown> 10zl

" Center screen on current line
nnoremap k kzz
vnoremap k kzz
nnoremap j jzz
vnoremap j jzz
nnoremap G Gzz
vnoremap G Gzz
nnoremap <C-End> Gzz
vnoremap <C-End> Gzz
nnoremap <Up> kzz
vnoremap <Up> kzz
nnoremap <Down> jzz
vnoremap <Down> jzz
nnoremap <C-u> <C-u>zz
vnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz
vnoremap <C-d> <C-d>zz
nnoremap <PageUp> <C-u>zz
vnoremap <PageUp> <C-u>zz
nnoremap <PageDown> <C-d>zz
vnoremap <PageDown> <C-d>zz
inoremap <PageUp> <Esc><C-u>zzi
inoremap <PageDown> <Esc><C-d>zzi

" Saner behavior of n and N - center search and open folds
nnoremap <expr> n 'Nn'[v:searchforward].'zzzv'
xnoremap <expr> n 'Nn'[v:searchforward]
onoremap <expr> n 'Nn'[v:searchforward]
nnoremap <expr> N 'nN'[v:searchforward].'zzzv'
xnoremap <expr> N 'nN'[v:searchforward]
onoremap <expr> N 'nN'[v:searchforward]

" Join line below cursor while maintaining cursor position
nnoremap J mzJ`z

"" Line Operations
" [L]ines [J]oin by delimiter in file
nnoremap <Leader>lj ggvG<Up>:s/\n//<Left>
" [L]ines [J]oin by delimiter in visual selection
vnoremap <Leader>lj <Up>:s/\n//<Left>
" [L]ine [S]plit by delimiter
nnoremap <Leader>ls <Esc><S-v>:s//\r/g<Left><Left><Left><Left><Left>
vnoremap <Leader>ls <Esc><S-v>:s//\r/g<Left><Left><Left><Left><Left>
" [C]ontiguous duplicate lines squeeze in file
nnoremap <silent> <Leader>lc mz:%!uniq<CR>`z
" [C]ontiguous duplicate lines squeeze in visual selection
vnoremap <silent> <Leader>lc mz:!uniq<CR>`z
" Remove [D]uplicate lines in file
nnoremap <silent> <Leader>ld mz:%!awk '\!a[$0]++'<CR>`z
" Remove [D]uplicate lines in visual selection
vnoremap <silent> <Leader>ld mz:!awk '\!a[$0]++'<CR>`z
" Convert file format to Uni[X]
nnoremap <silent> <Leader>lx :w <Bar> e ++ff=dos <Bar> set ff=unix <Bar> w<CR>
" Convert file format to Uni[X]
vnoremap <silent> <Leader>lx :w <Bar> e ++ff=dos <Bar> set ff=unix <Bar> w<CR>
" Remove [L]ines [E]mpty in file
nnoremap <silent> <Leader>le :g/^$/d<CR>

"" Json Line Operations
" Pretty print json
nnoremap <silent> <Leader>jq :%!jq<CR>
vnoremap <silent> <Leader>jq :!jq<CR>

"" Format Operations
" [F]ormat end of [L]ines in file
nnoremap <silent> <Leader>fl mz:%s/\s\+$//<CR>`z
" [F]ormat end of [L]ines in visual selection
vnoremap <silent> <Leader>fl mz:s/\s\+$//<CR>`z
" cat -s to squeeze-blank
" $(where cat|tail -1) to identify the default command if it has been aliased
" [F]ormat [C]ontiguous empty lines in file
nnoremap <silent> <Leader>fc mz:%!$(where cat<Bar>tail -1) -s<CR>`z
" [F]ormat [C]ontiguous empty lines in visual selection
vnoremap <silent> <Leader>fc mz:!$(where cat<Bar>tail -1) -s<CR>`z

" Remap C-c to Esc
inoremap <C-c> <Esc>

" kj to Esc
inoremap kj <Esc>
vnoremap kj <Esc>
inoremap KJ <Esc>
vnoremap KJ <Esc>

" Remap Home/End to toggle between start/end of line
nnoremap <expr> <Home> charcol(".") == indent(line(".")) + 1 ? "0" : "^"
vnoremap <expr> <Home> charcol(".") == indent(line(".")) + 1 ? "0" : "^"
inoremap <expr> <Home> charcol(".") == indent(line(".")) + 1 ? "<Esc>0i" : "<Esc>^i"
nnoremap <expr> 0 charcol(".") == indent(line(".")) + 1 ? "0" : "^"
vnoremap <expr> 0 charcol(".") == indent(line(".")) + 1 ? "0" : "^"
nnoremap <expr> <End> charcol(".") == charcol("$")-1 ? "g_" : "$"
vnoremap <expr> <End> charcol(".") == charcol("$") ? "g_" : "$"
inoremap <expr> <End> charcol(".") == charcol("$")-1 ? "<Esc>g_a" : "<Esc>$a"

" If EOL, then join, else delete char
nnoremap <expr> x charcol(".") == charcol("$") ? "J" : "x"

" Save file
nnoremap <C-s> :w<CR><Esc>
inoremap <C-s> <Esc>:w<CR><Esc>
xnoremap <C-s> <Esc>:w<CR><Esc>
snoremap <C-s> <Esc>:w<CR><Esc>

" Quit without saving with nonzero exit code
nnoremap ZC :cq<CR>

" New file
nnoremap <Leader>nf :enew<CR>

" Disable go to sleep keymap
nnoremap gs <nop>

" Quickfix list
nnoremap <Leader>lq :copen<CR>
nnoremap ]q :cnext<CR>
nnoremap [q :cprev<CR>

" Indenting to remain in visual mode
vnoremap < <gv
vnoremap > >gv

" Sentence case word
nnoremap <Leader>gS guiwv~

" Visual block mode
nnoremap <Bslash>B <C-v>
vnoremap <Bslash>B <C-v>

" Split and move
nnoremap <Leader><Bar> :vsp<CR><C-w><C-p>:bp<CR><C-w><C-p>
nnoremap <Leader>- :sp<CR><C-w><C-p>:bp<CR><C-w><C-p>

" Execute vim commands
nnoremap <Leader>xv :exec getline(".")<CR>

" Add stylua ignore above current line
nnoremap <Leader>li yyP^d$a-- stylua: ignore<Esc>

" Add semi-colon separator
nnoremap <silent> <Leader>; mzA;<Esc>`z
vnoremap <silent> <Leader>; mz<C-q>$A;<Esc>

" Change all lines
nnoremap <Leader>ca ggdGi

" Delete all lines
nnoremap <Leader>da ggdG

" Yank all lines
nnoremap <silent> <Leader>ya :%y<CR>

" Highlight all lines
nnoremap <silent> <Leader>va ggVG$

" Select to end/start of line
nnoremap L v$h
vnoremap L $h
nnoremap H v^
vnoremap H ^

" Search and replace word under cursor
nnoremap <Leader>/r :%s/<C-r><C-w>//g<Left><Left>

" Search whole word
nnoremap <Leader>/w /\<\><Left><Left>

" Search current without moving cursor
nnoremap * *N
vnoremap * *N
nnoremap # #n
vnoremap # #n
nnoremap g* g*N
vnoremap g* g*N
nnoremap g# g#n
vnoremap g# g#n

" Copy file name/path
nnoremap <silent> <Leader>cf :let @" = expand("%")<CR>
nnoremap <silent> <Leader>cp :let @" = expand("%:p")<CR>

" Delete into black hole register
vnoremap D "_d
nnoremap dD "_dd
vnoremap C "_c
nnoremap cC "_cc

" Insert tab space in normal mode
nnoremap <Tab> i<Tab><Esc>

" Edit macros
nnoremap <Leader>m :<c-u><c-r><c-r>='let @'. v:register .' = '. string(getreg(v:register))<CR><c-f><left>

" Custom toggles
nnoremap <Bslash>n :set nonu! nornu!<CR>
vnoremap <Bslash>n :set nonu! nornu!<CR>

" Buffer list
nnoremap ]b :bnext<CR>
nnoremap [b :bprev<CR>

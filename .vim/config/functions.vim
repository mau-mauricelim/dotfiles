" Toggle virtualedit
function! ToggleVirtualEdit()
    if &virtualedit == 'onemore'
        set virtualedit=all
        echo "virtualedit=all"
    else
        set virtualedit=onemore
        echo "virtualedit=onemore"
    endif
endfunction
nnoremap <Bslash>V :call ToggleVirtualEdit()<CR>
vnoremap <Bslash>V :call ToggleVirtualEdit()<CR>

" Toggle clipboard
function! ToggleClipboard()
    if &clipboard == 'unnamedplus'
        set clipboard=unnamed
        echo "clipboard=unnamed"
    elseif &clipboard == 'unnamed'
        set clipboard=
        echo "clipboard="
    else
        set clipboard=unnamedplus
        echo "clipboard=unnamedplus"
    endif
endfunction
nnoremap <Bslash>p :call ToggleClipboard()<CR>
vnoremap <Bslash>p :call ToggleClipboard()<CR>

" Toggle signcolumn
function! ToggleSigncolumn()
    if &signcolumn == 'yes'
        set signcolumn=no
        echo "signcolumn=no"
    else
        set signcolumn=yes
        echo "signcolumn=yes"
    endif
endfunction
nnoremap <Bslash>s :call ToggleSigncolumn()<CR>
vnoremap <Bslash>s :call ToggleSigncolumn()<CR>

" Remove trailing blank lines
function! TrimEndLines()
    let save_cursor = getpos(".")
    silent! %s#\($\n\s*\)\+\%$##
    call setpos('.', save_cursor)
endfunction
nnoremap <silent> <Leader>fe :call TrimEndLines()<CR>

" Toggle alternate or last file
function! AltFileOrOldFile()
    if @# != ''
        execute 'buffer #'
    elseif !empty(v:oldfiles)
        execute 'edit ' . v:oldfiles[0]
    else
        echo "No alternate file available"
    endif
endfunction
nnoremap <silent> <Leader>. :call AltFileOrOldFile()<CR>
vnoremap <silent> <Leader>. :call AltFileOrOldFile()<CR>

" Netrw
function! NetrwMapping()
    nnoremap <buffer> <silent> q :bdelete<CR>
    nmap <buffer> h -
    nmap <buffer> <Left> -
    nmap <buffer> l <CR>
    nmap <buffer> <Right> <CR>
endfunction

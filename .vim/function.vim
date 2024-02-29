" Vimscript function needs to start with a capital letter
" Function to source file if it exists
function! SourceIfExists(file)
    " Prefix arguments with a vimscript function with `a:` to indicate argument scope
    if filereadable(expand(a:file))
        exe 'source' a:file
    endif
endfunction

" Toggle virtual edit mode between onemore and all
function ToggleVirtualedit()
    if &virtualedit == "onemore"
        echo "virtualedit=all"
        set virtualedit=all
    else
        echo "virtualedit=onemore"
        set virtualedit=onemore
    endif
endfunction

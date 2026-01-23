" Disable auto comment new lines
augroup disable_auto_comment
  autocmd!
  autocmd BufEnter * set fo-=c fo-=r fo-=o
augroup END

" Center screen on buffer read
augroup center_screen
  autocmd!
  autocmd BufReadPre * normal! zz
augroup END

" Add new filetype mappings
augroup filetype_mappings
  autocmd!
  autocmd BufRead,BufNewFile *.q setfiletype q
  autocmd BufRead,BufNewFile *.k setfiletype k
augroup END

" Go to last location when opening a buffer
augroup last_location
  autocmd!
  autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") && &filetype !~# 'gitcommit' | exe "normal! g'\"" | endif
augroup END

" Close some filetypes with q
augroup close_with_q
  autocmd!
  autocmd FileType help,qf nnoremap <buffer> <silent> q :close<CR>
  autocmd FileType help,qf setlocal nobuflisted
augroup END

" netrw mappings
augroup netrw_mappings
  autocmd!
  autocmd FileType netrw call NetrwMapping()
augroup END

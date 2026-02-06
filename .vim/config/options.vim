" Set <space> as the leader key
let mapleader = ' '
let maplocalleader = ' '

" Syntax highlighting
filetype plugin indent on
syntax on

" Wildmenu
set wildmenu
set wildmode=longest:full,full

" Persistent undo - custom directories
set undodir=$XDG_DATA_HOME/vim/undo
set directory=$XDG_DATA_HOME/vim/swap
set backupdir=$XDG_DATA_HOME/vim/backup
set viminfo+=n$XDG_DATA_HOME/vim/viminfo

" Make line numbers default
set number relativenumber

" Enable mouse mode
set mouse=a
set mousemodel=extend

" Clipboard settings
set clipboard=unnamed

" Enable break indent
" set breakindent

" Save undo history
set undofile
set undolevels=100000
set undoreload=100000

" Disable swapfile
set noswapfile

" Case-insensitive searching
set ignorecase smartcase

" Keep signcolumn auto by default
set signcolumn=auto

" Set textwidth for gq
set textwidth=120
set formatoptions-=t

" Decrease update time
set updatetime=100

" Decrease mapped sequence wait time
set timeoutlen=300

" Configure how new splits should be opened
set splitright splitbelow

" Sets how vim will display certain whitespace
set list
set listchars=tab:»\ ,trail:·,nbsp:␣

" Show which line your cursor is on
set cursorline

" Tab settings
set tabstop=4
set shiftwidth=4
set expandtab

" No wrap
set nowrap

" Allow cursor to move just past end of line
set virtualedit=onemore

" Set highlight on search
set hlsearch

" Disable audible and visual bells
set noerrorbells novisualbell
set t_vb=

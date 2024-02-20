" Vim plug
" Make sure you use single quotes
call plug#begin()
    Plug 'navarasu/onedark.nvim'
    Plug 'nvim-tree/nvim-web-devicons'
    Plug 'nvim-tree/nvim-tree.lua', { 'on': 'NvimTreeToggle' }
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
    Plug 'akinsho/toggleterm.nvim', { 'tag': '*' }
    Plug 'airblade/vim-gitgutter'
    Plug 'preservim/nerdcommenter'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
    Plug 'folke/noice.nvim'
    Plug 'MunifTanjim/nui.nvim'
    Plug 'rcarriga/nvim-notify'
call plug#end()

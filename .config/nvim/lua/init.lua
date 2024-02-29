-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- onedark.nvim
require('onedark').setup {
    style = 'cool'
}
require('onedark').load()

-- nvim-tree.lua
require('user/nvim-tree')

-- lualine.nvim
require('lualine').setup()

-- bufferline.nvim
require('bufferline').setup{}

-- toggleterm.nvim
require('user/toggleterm')

-- telescope.nvim
require('user/telescope')

-- noice.nvim
require('user/noice')

-- mini.nvim
require('user/mini')

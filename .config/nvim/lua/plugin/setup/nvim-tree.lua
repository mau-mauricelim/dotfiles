-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- optionally enable 24-bit colour
vim.opt.termguicolors = true

return {
  'nvim-tree/nvim-tree.lua',
  version = '*',
  cmd = { 'NvimTreeOpen', 'NvimTreeFindFile' },
  keys = {
    { '<Leader>t', '<cmd>NvimTreeFindFileToggle<CR>', { desc = 'Toggle [T]ree', silent = true } },
  },
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- Pass to setup along with your other options
    -- stylua: ignore
    require('nvim-tree').setup({
      on_attach = function(bufnr)
        local api = require('nvim-tree.api')
        local function opts(desc)
          return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        -- default mappings
        api.config.mappings.default_on_attach(bufnr)
        -- custom mappings
        vim.keymap.set('n', '<C-t>', api.tree.change_root_to_parent, opts('Up'))
        vim.keymap.set('n', '?',     api.tree.toggle_help,           opts('Help'))
      end,
    })

    -- Enable integration after nvim-tree is loaded
    local status_ok, fidget = pcall(require, 'fidget')
    if status_ok then
      fidget.setup({
        integration = {
          ['nvim-tree'] = { enable = true },
        },
      })
    end

    -- QuitPre event that checks if it's the last window and also aware of floating windows
    vim.api.nvim_create_autocmd('QuitPre', {
      callback = function()
        local tree_wins = {}
        local floating_wins = {}
        local wins = vim.api.nvim_list_wins()
        for _, w in ipairs(wins) do
          local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
          if bufname:match('NvimTree_') ~= nil then
            table.insert(tree_wins, w)
          end
          if vim.api.nvim_win_get_config(w).relative ~= '' then
            table.insert(floating_wins, w)
          end
        end
        if 1 == #wins - #floating_wins - #tree_wins then
          -- Should quit, so we close all invalid windows.
          for _, w in ipairs(tree_wins) do
            vim.api.nvim_win_close(w, true)
          end
        end
      end,
    })
  end,
}
return {
  'stevearc/oil.nvim',
  config = function()
    local oil = require("oil")
    local actions = require("oil.actions")
    oil.setup({
      view_options = {
        show_hidden = true,
      }
    })
    vim.keymap.set('n', '-', oil.open,                  { desc = 'Open parent directory' })
    vim.keymap.set('n', '_', actions.open_cwd.callback, { desc = 'Open current working directory' })
  end,
}
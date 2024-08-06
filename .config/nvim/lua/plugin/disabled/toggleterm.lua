return {
  'akinsho/toggleterm.nvim',
  version = '*',
  event = 'VeryLazy',
  -- Enable if not using tmux
  enabled = os.getenv('TMUX') == nil,
  config = function()
    require('toggleterm').setup()
    -- Switching between Vim windows is also easy. Use the Ctrl-W prefix plus the direction of the window you want to move to.
    vim.keymap.set('n', '<C-\\>', '<cmd>ToggleTerm<CR>')
    vim.keymap.set('i', '<C-\\>', '<cmd>ToggleTerm<CR>')
    vim.keymap.set('t', '<C-\\>', '<cmd>ToggleTerm<CR>')
  end,
}

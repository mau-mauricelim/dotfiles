return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  event = 'VeryLazy',
  opts = {
    indent = {
      char = '│',
      tab_char = '│',
    },
    scope = { enabled = false },
    exclude = {
      filetypes = { 'help', 'dashboard', 'lazy', 'mason', 'notify', 'toggleterm', 'lazyterm' },
    },
  },
  keys = {
    { vim.g.option_toggle_prefix .. 'I', mode = { 'n', 'v' }, '<cmd>IBLToggle<CR>', desc = "Toggle 'indent-blankline'" },
  },
}

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
    { '<Leader>il', '<cmd>IBLToggle<CR>', { desc = 'Toggle [I]ndent [L]ines', silent = true } },
  },
}
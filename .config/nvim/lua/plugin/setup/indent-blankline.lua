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
    { '<Leader>ti', '<cmd>IBLToggle<CR>', desc = '[T]oggle [I]ndent lines' },
  },
}

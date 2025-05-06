return {
  'folke/trouble.nvim',
  event = 'VeryLazy',
  opts = {}, -- for default options, refer to the configuration section for custom setup.
  cmd = 'Trouble',
  keys = {
    {
      '<Leader>xx',
      '<cmd>Trouble diagnostics toggle<CR>',
      desc = 'Diagnostics (Trouble)',
    },
    {
      '<Leader>xX',
      '<cmd>Trouble diagnostics toggle filter.buf=0<CR>',
      desc = 'Buffer Diagnostics (Trouble)',
    },
    {
      '<Leader>cs',
      '<cmd>Trouble symbols toggle focus=false<CR>',
      desc = 'Symbols (Trouble)',
    },
    {
      '<Leader>cl',
      '<cmd>Trouble lsp toggle focus=false win.position=right<CR>',
      desc = 'LSP Definitions / references / ... (Trouble)',
    },
    {
      '<Leader>xL',
      '<cmd>Trouble loclist toggle<CR>',
      desc = 'Location List (Trouble)',
    },
    {
      '<Leader>xQ',
      '<cmd>Trouble qflist toggle<CR>',
      desc = 'Quickfix List (Trouble)',
    },
  },
  specs = {
    'folke/snacks.nvim',
    opts = function(_, opts)
      return vim.tbl_deep_extend('force', opts or {}, {
        picker = {
          actions = require('trouble.sources.snacks').actions,
          win = {
            input = {
              keys = {
                ['<c-t>'] = {
                  'trouble_open',
                  mode = { 'n', 'i' },
                },
              },
            },
          },
        },
      })
    end,
  },
}

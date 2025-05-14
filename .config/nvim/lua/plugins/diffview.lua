return {
  'sindrets/diffview.nvim',
  opts = {},
  keys = {
    { '<Leader>do', ':DiffviewOpen<CR>', desc = 'DiffviewOpen' },
    { '<Leader>dc', ':DiffviewClose<CR>', desc = 'DiffviewClose' },
    { '<Leader>dt', ':DiffviewToggleFiles<CR>', desc = 'DiffviewToggleFiles' },
    { '<Leader>df', ':DiffviewFileHistory %<CR>', desc = 'DiffviewFileHistory %', mode = { 'n' } },
    { '<Leader>df', ":'<,'>DiffviewFileHistory<CR>", desc = 'DiffviewFileHistory', mode = { 'v' } },
    { '<Leader>dF', ':DiffviewFileHistory<CR>', desc = 'DiffviewFileHistory', mode = { 'n', 'v' } },
  },
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
}

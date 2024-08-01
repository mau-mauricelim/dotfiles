return {
  'christoomey/vim-tmux-navigator',
  -- Enable if using tmux
  enabled = os.getenv('TMUX') ~= nil,
  cmd = {
    'TmuxNavigateLeft',
    'TmuxNavigateDown',
    'TmuxNavigateUp',
    'TmuxNavigateRight',
    'TmuxNavigatePrevious',
  },
  keys = {
    { '<C-h>', '<cmd><C-u>TmuxNavigateLeft<CR>' },
    { '<C-j>', '<cmd><C-u>TmuxNavigateDown<CR>' },
    { '<C-k>', '<cmd><C-u>TmuxNavigateUp<CR>' },
    { '<C-l>', '<cmd><C-u>TmuxNavigateRight<CR>' },
    { '<C-\\>', '<cmd><C-u>TmuxNavigatePrevious<CR>' },
  },
}

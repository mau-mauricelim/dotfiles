return {
  'kdheepak/lazygit.nvim',
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  -- Optional for floating window border decoration
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  -- Setting the keybinding for LazyGit with 'keys' is recommended in
  -- order to load the plugin when the command is run for the first time
  keys = {
    { '<Leader>lg', '<cmd>LazyGit<CR>', desc = 'LazyGit' },
    -- { '<Leader>gl', '<cmd>LazyGit<CR>1a<CR>', desc = '[G]it [L]og all branch' },
    { '<Leader>gl', '<cmd>LazyGit<CR>4++<CR>', desc = '[G]it [L]og current branch' },
  },
}

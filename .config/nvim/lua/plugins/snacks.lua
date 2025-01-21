return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      sections = {
        { section = 'header' },
        { icon = ' ', title = 'Keymaps', section = 'keys', indent = 2, padding = 1 },
        { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
        { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
        { section = 'startup' },
      },
    },
    input = { enabled = true },
    quickfile = { enabled = true },
    lazygit = {
      win = { style = 'dashboard' },
    },
  },
  keys = {
    { '<leader>Z',  function() Snacks.zen.zoom() end, desc = 'Toggle Zoom' },
    { '<leader>,',  function() Snacks.scratch() end, desc = 'Toggle Scratch Buffer' },
    { '<leader>S',  function() Snacks.scratch.select() end, desc = 'Select Scratch Buffer' },
    { '<leader>bd', function() Snacks.bufdelete() end, desc = 'Delete Buffer' },
    { '<leader>rf', function() Snacks.rename.rename_file() end, desc = '[R]ename [F]ile' },
    { '<leader>gb', function() Snacks.git.blame_line() end, desc = 'Git Blame Line' },
    { '<leader>lg', function() Snacks.lazygit() end, desc = 'Lazygit' },
    { vim.g.option_toggle_prefix .. 'gl', function() Snacks.lazygit.log() end, desc = 'Lazygit Log (cwd)' },
    { vim.g.option_toggle_prefix .. 'gf', function() Snacks.lazygit.log_file() end, desc = 'Lazygit Current File History' },
  },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesActionRename',
      callback = function(event)
        Snacks.rename.on_rename_file(event.data.from, event.data.to)
      end,
    })
  end,
}

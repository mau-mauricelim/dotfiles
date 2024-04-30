return {
  'folke/persistence.nvim',
  event = { 'BufReadPre', 'BufNewFile' }, -- this will only start session saving when an actual file was opened
  opts = { options = vim.opt.sessionoptions:get() },
  -- stylua: ignore
  keys = {
    { '<leader>ps', function() require('persistence').save() end,                desc = '[S]ave Session' },
    { '<leader>pr', function() require('persistence').load() end,                desc = '[R]estore Session' },
    { '<leader>pl', function() require('persistence').load({ last = true }) end, desc = 'Restore [L]ast Session' },
    {
      '<leader>pd',
      function()
        local persistence = require('persistence')
        persistence.stop()
        os.execute('rm -r ' .. require('persistence.config').options.dir .. '/*')
      end,
      desc = '[D]elete all session files',
    },
  },
  init = function()
    local _, argv = next(vim.fn.argv())
    -- An actual file was opened
    if argv ~= nil then
      -- Not a directory
      if vim.fn.isdirectory(argv) == 0 then
        local current_buffer = vim.fn.expand('%')
        -- Restore last session
        require('persistence').load()
        -- Remove [No Name] and directory buffers
        pcall(ClearBuffers)
        -- Switch back to current buffer
        vim.cmd('buffer ' .. current_buffer)
      end
    end
  end,
}

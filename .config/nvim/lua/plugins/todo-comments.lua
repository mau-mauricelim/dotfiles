-- Usage:
-- Todo matches on any text that starts with one of your defined keywords (or alt) followed by a colon:
--
-- Examples:
-- FIX: Bug found
-- WARN: You've been warned
-- HACK: What the hack!
-- TODO: I'll do it later...
-- NOTE: Adding a note
-- PERF: This is perfect!
-- TEST: All unit tests passed!
--
return { -- highlight and search for todo comments
  'folke/todo-comments.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-lua/plenary.nvim' },
  -- stylua: ignore
  config = function()
    local colors = require('colors')
    require('todo-comments').setup({
      -- keywords recognized as todo comments
      keywords = {
        FIX = {
          icon = ' ', -- icon used for the sign, and in search results
          color = 'error', -- can be a hex color, or a named color (see below)
          alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }, -- a set of other keywords that all map to this FIX keywords
          -- signs = false, -- configure signs for some keywords individually
        },
        WARN = { icon = ' ', color = 'warning', alt = { 'WARNING' } },
        HACK = { icon = ' ', color = 'hack' },
        PERF = { icon = ' ', color = 'perf', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
        TODO = { icon = ' ', color = 'todo' },
        NOTE = { icon = ' ', color = 'hint', alt = { 'INFO', 'HINT'} },
        TEST = { icon = '⏲ ', color = 'test', alt = { 'DEBUG', 'TESTING', 'PASSED', 'FAILED' } },
      },
      -- list of named colors where we try to extract the guifg from the
      -- list of highlight groups or use the hex color if hl not found as a fallback
      colors = {
        error   = { colors.red },
        warning = { colors.orange },
        hack    = { colors.yellow },
        perf    = { colors.green },
        todo    = { colors.blue },
        hint    = { colors.cyan },
        test    = { colors.purple },
        default = { colors.light_grey },
      },
    })
    vim.keymap.set('n', '[t', function() require('todo-comments').jump_prev() end, { desc = 'Go to previous [T]odo comment' })
    vim.keymap.set('n', ']t', function() require('todo-comments').jump_next() end, { desc = 'Go to next [T]odo comment' })
  end,
}

-- NOTE: Plugins can also be added by using a table,
-- with the first argument being the link and the following
-- keys can be used to configure plugin behavior/loading/etc.
--
-- Use `opts = {}` to force a plugin to be loaded.
--
--  This is equivalent to:
--    require('<plugin>').setup({})
return { -- "gc" to comment visual regions/lines
  'numToStr/Comment.nvim',
  event = 'VeryLazy',
  config = function()
    require('Comment').setup()
    -- Map Ctrl-/
    vim.keymap.set('n', '<C-_>', 'gcc', { desc = 'Comment with Line Comment', remap = true })
    vim.keymap.set('v', '<C-_>', 'gc', { desc = 'Comment with Line Comment', remap = true })
  end,
}
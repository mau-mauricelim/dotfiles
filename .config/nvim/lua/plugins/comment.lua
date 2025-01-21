return { -- "gc" to comment visual regions/lines
  'numToStr/Comment.nvim',
  event = 'VeryLazy',
  config = function()
    require('Comment').setup()
    -- Map Ctrl-/
    -- vim.keymap.set('n', '<C-_>', 'gcc', { desc = 'Comment with Line Comment', remap = true })
    -- vim.keymap.set('v', '<C-_>', 'gc', { desc = 'Comment with Line Comment', remap = true })
  end,
}

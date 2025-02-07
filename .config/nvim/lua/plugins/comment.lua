return { -- "gc" to comment visual regions/lines
  'numToStr/Comment.nvim',
  event = 'VeryLazy',
  config = function()
    require('Comment').setup()
  end,
}

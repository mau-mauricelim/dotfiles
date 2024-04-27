-- WARN: Closing buffers using UI does not save modifications!
return { -- tabpage integration
  'akinsho/bufferline.nvim',
  version = '*',
  event = 'VimEnter',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {},
}
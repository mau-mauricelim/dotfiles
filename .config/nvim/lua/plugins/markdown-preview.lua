-- install with yarn or npm
return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  keys = {
    { '<Leader>tm', '<cmd>MarkdownPreviewToggle<CR>', desc = 'Toggle [M]arkdown preview' },
  },
  ft = { 'markdown' },
  -- BUG: Vim:E117: Unknown function: mkdp#util#install when install by lazy.nvim
  -- https://github.com/iamcco/markdown-preview.nvim/issues/690
  -- If build fail, manually run `:call mkdp#util#install()`
  build = function()
    vim.fn['mkdp#util#install']()
  end,
}

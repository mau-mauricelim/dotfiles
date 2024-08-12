-- install with yarn or npm
return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  keys = {
    { '<Leader>tm', '<cmd>MarkdownPreviewToggle<CR>', desc = 'Toggle [M]arkdown preview' },
  },
  ft = { 'markdown' },
  build = function()
    require('lazy').load({ plugins = 'markdown-preview.nvim' })
    vim.fn['mkdp#util#install']()
  end,
}

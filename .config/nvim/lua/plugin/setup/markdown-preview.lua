-- install without yarn or npm
return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  keys = {
    { '<Leader>tm', '<cmd>MarkdownPreviewToggle<CR>', desc = 'Toggle [M]arkdown preview' },
  },
  ft = { 'markdown' },
  -- stylua: ignore
  build = function() vim.fn['mkdp#util#install']() end,
}

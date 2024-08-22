-- install with yarn or npm
return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  keys = {
    { '<Leader>tm', '<cmd>MarkdownPreviewToggle<CR>', desc = 'Toggle [M]arkdown preview' },
  },
  build = "cd app && yarn install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  ft = { 'markdown' },
}

-- install without yarn or npm
return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  keys = {
    { '<Leader>md', '<cmd>MarkdownPreviewToggle<CR>', { desc = 'Toggle [M]arkdown [P]review', silent = true } },
  },
  ft = { 'markdown' },
  -- stylua: ignore
  build = function() vim.fn['mkdp#util#install']() end,
}
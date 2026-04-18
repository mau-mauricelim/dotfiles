### q language server

- autocompletion
- definitionProvider
- referencesProvider

### setup q language server for neovim

1. install qls

```
npm --global i @jo.shinonome/qls
```

2. install [vim-q-syntax](https://github.com/jshinonome/vim-q-syntax)

3. use lazy plugin manager and add following configuration to `~/.config/nvim/init.lua`

```
require('lazy').setup({
  'neovim/nvim-lspconfig',
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/nvim-cmp",
  'hrsh7th/cmp-vsnip',
  'hrsh7th/vim-vsnip',
})


local cmp = require 'cmp'
cmp.setup({
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'buffer' },
  }),
  window = {
    completion = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'q',
  callback = function()
    vim.lsp.start({
      name = 'q language server',
      cmd = { 'qls', '--stdio' },
      filetypes = { 'q' },
      root_dir = vim.fs.dirname(vim.fs.find({ 'src' }, { upward = true })[1]),
    })
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  end,
})

```

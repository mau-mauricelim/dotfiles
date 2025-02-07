-- Custom goto definition
vim.opt.iskeyword:append('.')

local status_fzf_lua, fzf_lua = pcall(require, 'fzf-lua')
-- stylua: ignore
if status_fzf_lua then
  -- Naive solution
  local function Goto_definitons() fzf_lua.grep({ search = vim.fn.expand('<cword>') .. ':' }) end
  local function Goto_references() fzf_lua.grep({ search = vim.fn.expand('<cword>') }) end
  vim.keymap.set('n', 'gd', Goto_definitons, { desc = '[G]oto [D]efinition' })
  -- Does not exclude definition
  -- `gr` is used by mini-operators
  vim.keymap.set('n', 'gR', Goto_references, { desc = '[G]oto [R]eferences' })
end

local status_blink, _ = pcall(require, 'blink.cmp')
if not status_blink then
  -- Autocompletion and signature help plugin
  local status_mini, completion = pcall(require, 'mini.completion')
  -- stylua: ignore
  if status_mini then completion.setup() end
end

-- Comment string
vim.bo.commentstring = '/ %s'
vim.keymap.set('n', 'gcn', 'ONOTE: <Esc>gccI/<End>', { desc = 'NOTE Comment insert above', remap = true })
vim.keymap.set('n', 'gct', 'OTODO: <Esc>gccI/<End>', { desc = 'TODO Comment insert above', remap = true })

-- Disable autopair for '`'
vim.keymap.set('i', '`', '`', { buffer = 0 })

-- qls override if it exists
vim.lsp.start({
  name = 'q language server',
  cmd = { 'qls', '--stdio' },
  filetypes = { 'q' },
  root_dir = vim.fs.dirname(vim.fs.find({ 'src' }, { upward = true })[1]),
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

vim.notify('q.lua loaded!')

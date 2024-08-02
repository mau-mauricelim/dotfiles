-- Custom goto definition
vim.opt.iskeyword:append('.')

local status_telescope, builtin = pcall(require, 'telescope.builtin')
-- stylua: ignore
if status_telescope then
  -- Naive solution
  builtin.goto_def = function() builtin.grep_string({ search = vim.fn.expand('<cword>') .. ':' }) end
  builtin.goto_ref = function() builtin.grep_string({ search = vim.fn.expand('<cword>') }) end
  vim.keymap.set('n', 'gd', builtin.goto_def, { desc = '[G]oto [D]efinition' })
  -- Does not exclude definition
  vim.keymap.set('n', 'gr', builtin.goto_ref, { desc = '[G]oto [R]eferences' })
end

-- Autocompletion and signature help plugin
local status_mini, completion = pcall(require, 'mini.completion')
-- stylua: ignore
if status_mini then completion.setup() end

-- Comment string
vim.bo.commentstring = '/%s'
-- Disable autopair for '`'
vim.keymap.set('i', '`', '`', { buffer = 0 })
-- Add semi-colon separator
vim.keymap.set({ 'n', 'v' }, '<Leader>;', 'mz:norm A;<CR>`z', { desc = 'Add semi-colon separator', silent = true })

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

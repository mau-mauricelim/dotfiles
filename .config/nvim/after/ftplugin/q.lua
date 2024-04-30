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

vim.notify('q.lua loaded!')

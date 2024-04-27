-- Disable mini.pair based on buffer file type
vim.keymap.set('i', '`', '`', { buffer = 0 })

-- Autocompletion and signature help plugin
local status_ok, mini_completion = pcall(require, 'mini.completion')
if status_ok then mini_completion.setup() end
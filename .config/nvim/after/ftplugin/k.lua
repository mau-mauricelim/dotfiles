-- Autocompletion and signature help plugin
local status_ok, mini_completion = pcall(require, 'mini.completion')
if status_ok then mini_completion.setup() end

vim.notify('k.lua loaded!')

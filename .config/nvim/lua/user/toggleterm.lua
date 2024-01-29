-- Switching between Vim windows is also easy. Use the Ctrl + W prefix plus the direction of the window you want to move to.
vim.keymap.set('n', '<C-\\>', '<Cmd>ToggleTerm<CR>')
vim.keymap.set('i', '<C-\\>', '<Cmd>ToggleTerm<CR>')
vim.keymap.set('t', '<C-\\>', '<Cmd>ToggleTerm<CR>')

require('toggleterm').setup{}

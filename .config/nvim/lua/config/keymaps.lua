-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- List of all commands for each mode
-- :h index
-- stylua: ignore start

-- Redraw / Clear hlsearch / Diff Update on pressing <Esc> in normal mode
vim.keymap.set(
  'n',
  '<Esc>',
  '<cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>',
  { desc = 'Redraw / Clear hlsearch / Diff Update', silent = true }
)

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<Left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<Right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<Up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<Down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use Ctrl-<HJKL> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Side scroll
-- zL - Move the view on the text half a screenwidth to the right
-- zs - Scroll the text horizontally to position the cursor at the start (left side) of the screen
vim.keymap.set({ 'n', 'v' }, '<S-ScrollWheelUp>', '10zh')
vim.keymap.set({ 'n', 'v' }, '<S-ScrollWheelDown>', '10zl')

-- Center screen on current line
vim.keymap.set({ 'n', 'v' }, 'k', 'kzz')
vim.keymap.set({ 'n', 'v' }, 'j', 'jzz')
vim.keymap.set({ 'n', 'v' }, 'G', 'Gzz')
vim.keymap.set({ 'n', 'v' }, '<C-End>', 'Gzz')
vim.keymap.set({ 'n', 'v' }, '<Up>', 'kzz')
vim.keymap.set({ 'n', 'v' }, '<Down>', 'jzz')
vim.keymap.set({ 'n', 'v' }, '<C-u>', '<C-u>zz')
vim.keymap.set({ 'n', 'v' }, '<C-d>', '<C-d>zz')
vim.keymap.set({ 'n', 'v' }, '<PageUp>', '<C-u>zz')
vim.keymap.set({ 'n', 'v' }, '<PageDown>', '<C-d>zz')
vim.keymap.set('i', '<PageUp>', '<Esc><C-u>zzi')
vim.keymap.set('i', '<PageDown>', '<Esc><C-d>zzi')

-- `n` to always search forward and `N` backward
-- https://github.com/mhinz/vim-galore?tab=readme-ov-file#saner-behavior-of-n-and-n
-- Center search and open folds for this line
vim.keymap.set('n', 'n', "'Nn'[v:searchforward].'zzzv'", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('n', 'N', "'nN'[v:searchforward].'zzzv'", { expr = true, desc = 'Prev Search Result' })
vim.keymap.set('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })
vim.keymap.set('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })

-- Joins line below cursor
-- `mz` saves the cursor position using the mark `z`, ` `z` goes back to mark `z`
vim.keymap.set('n', 'J', 'mzJ`z')

-- Line Operations
vim.keymap.set('n', '<Leader>lj', 'ggvG<Up>:s/\\n//<Left>', { desc = '[L]ines [J]oin by delimiter in file' })
vim.keymap.set('v', '<Leader>lj', '<Up>:s/\\n//<Left>', { desc = '[L]ines [J]oin by delimiter in visual selection' })
vim.keymap.set({ 'n', 'v' }, '<Leader>ls', '<Esc><S-v>:s//\\r/g<Left><Left><Left><Left><Left>', { desc = '[L]ine [S]plit by delimiter' })
vim.keymap.set('n', '<Leader>lc', 'mz<cmd>%!uniq<CR>`z', { desc = '[C]ontiguous duplicate lines squeeze in file', silent = true })
vim.keymap.set('v', '<Leader>lc', 'mz:!uniq<CR>`z', { desc = '[C]ontiguous duplicate lines squeeze in visual selection', silent = true })
vim.keymap.set('n', '<Leader>ld', "mz<cmd>%!awk '\\!a[$0]++'<CR>`z", { desc = 'Remove [D]uplicate lines in file', silent = true })
vim.keymap.set('v', '<Leader>ld', "mz:!awk '\\!a[$0]++'<CR>`z", { desc = 'Remove [D]uplicate lines in visual selection', silent = true })
vim.keymap.set('n', '<Leader>lx', '<cmd>w | e ++ff=dos | set ff=unix | w<CR>', { desc = 'Convert file format to Uni[X]', silent = true })
vim.keymap.set('v', '<Leader>lx', '<cmd>w | e ++ff=dos | set ff=unix | w<CR>', { desc = 'Convert file format to Uni[X]', silent = true })

-- Format Operations
vim.keymap.set('n', '<Leader>fl', 'mz<cmd>%s/\\s\\+$//<CR>`z', { desc = '[F]ormat end of [L]ines in file', silent = true })
vim.keymap.set('v', '<Leader>fl', 'mz:s/\\s\\+$//<CR>`z', { desc = '[F]ormat end of [L]ines in visual selection', silent = true })
-- cat -s to squeeze-blank
-- $(where cat|tail -1) to identify the default command if it has been aliased
vim.keymap.set('n', '<Leader>fc', 'mz<cmd>%!$(where cat|tail -1) -s<CR>`z', { desc = '[F]ormat [C]ontiguous empty lines in file', silent = true })
vim.keymap.set('v', '<Leader>fc', 'mz:!$(where cat|tail -1) -s<CR>`z', { desc = '[F]ormat [C]ontiguous empty lines in visual selection', silent = true })

-- Remap C-c to Esc
vim.keymap.set('i', '<C-c>', '<Esc>')
-- `kj` to Esc
vim.keymap.set({ 'i', 'v' }, 'kj', '<Esc>')

-- Remap Home/End to toggle between start/end of line and first/last non-blank space
vim.keymap.set({ 'n', 'v' }, '<Home>', 'charcol(".") == indent(line(".")) + 1 ? "0" : "^"', { expr = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '0', 'charcol(".") == indent(line(".")) + 1 ? "0" : "^"', { expr = true, silent = true })
vim.keymap.set('i', '<Home>', 'charcol(".") == indent(line(".")) + 1 ? "<Esc>0i" : "<Esc>^i"', { expr = true, silent = true })
vim.keymap.set('n', '<End>', 'charcol(".") == charcol("$")-1 ? "g_" : "$"', { expr = true, silent = true })
vim.keymap.set('v', '<End>', 'charcol(".") == charcol("$") ? "g_" : "$"', { expr = true, silent = true })
vim.keymap.set('i', '<End>', 'charcol(".") == charcol("$")-1 ? "<Esc>g_a" : "<Esc>$a"', { expr = true, silent = true })
-- If EOL, then join, else del char
vim.keymap.set('n', 'x', 'charcol(".") == charcol("$") ? "J" : "x"', { expr = true, silent = true })

-- Save file
vim.keymap.set({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><Esc>', { desc = 'Save file' })
-- `:cq` to quit, without saving, with a nonzero exit code to indicate failure - bash will not execute the command
vim.keymap.set('n', 'ZC', '<cmd>cq<CR>', { desc = 'Quit without saving with a nonzero exit code' })
-- New file
vim.keymap.set('n', '<Leader>nf', '<cmd>enew<CR>', { desc = '[N]ew [F]ile' })
-- Disable go to sleep keymap
vim.keymap.set('n', 'gs', '<nop>')

-- Quickfix list
vim.keymap.set('n', '<Leader>lq', '<cmd>copen<CR>', { desc = '[L]ist [Q]uickfix' })
vim.keymap.set('n', ']q', vim.cmd.cnext, { desc = 'Next [Q]uickfix' })
vim.keymap.set('n', '[q', vim.cmd.cprev, { desc = 'Previous [Q]uickfix' })

-- Indenting to remain in visual mode
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Sentence case word
vim.keymap.set('n', '<Leader>gS', 'guiwv~', { desc = '[S]entence case word' })

-- Visual block mode (Default Ctrl-V)
-- Ctrl-V is bound to paste in Windows Terminal, use Ctrl-Q instead
-- Shift-V for visual line mode
vim.keymap.set({ 'n', 'v' }, vim.g.option_toggle_prefix .. 'B', '<C-v>', { desc = 'Toggle visual block' })

-- Split and move
vim.keymap.set('n', '<Leader>|', '<cmd>vsp<CR><C-w><C-p><cmd>bp<CR><C-w><C-p>', { desc = 'Vertical [-] Split and move' })
vim.keymap.set('n', '<Leader>-', '<cmd>sp<CR><C-w><C-p><cmd>bp<CR><C-w><C-p>', { desc = 'Horizontal [|] Split and move' })

-- Execute vim and lua (print) commands
vim.keymap.set('n', '<Leader>lu', ':lua ', { desc = 'Run [Lu]a command' })
vim.keymap.set('n', '<Leader>lp', ':lua P()<Left>', { desc = 'Run [L]ua [P]rint command' })
vim.keymap.set('n', '<Leader>xv', '<cmd>exec getline(".")<CR>', { desc = 'E[X]ecute current line in Vim' })
vim.keymap.set('n', '<Leader>xl', '<cmd>exec "lua ".getline(".")<CR>', { desc = 'E[X]ecute current line in Lua' })
vim.keymap.set('n', '<Leader>xp', '<cmd>exec "lua P(".getline(".").")"<CR>', { desc = 'E[X]ecute current line in Lua print()' })

-- Add -- stylua: ignore above current line
vim.keymap.set('n', '<Leader>li', 'yyP^d$a-- stylua: ignore<Esc>', { desc = 'Add [L]ua [I]gnore above current line' })
-- Add semi-colon separator
vim.keymap.set({ 'n', 'v' }, '<Leader>;', 'mzA;<Esc>`z', { desc = 'Add semi-colon separator', silent = true })

-- Change all
vim.keymap.set('n', '<Leader>ca', 'ggdGi', { desc = '[C]hange [A]ll lines' })
-- Delete all
vim.keymap.set('n', '<Leader>da', 'ggdG', { desc = '[D]elete [A]ll lines' })
-- Yank all
vim.keymap.set('n', '<Leader>ya', '<cmd>%y<CR>', { desc = '[Y]ank [A]ll lines', silent = true })
-- Highlight all
vim.keymap.set('n', '<Leader>va', 'ggVG$', { desc = '[V]isual [A]ll lines', silent = true })

-- Select to end of line: similar to `C`, `D` and `Y`
vim.keymap.set('n', 'L', 'v$h', { desc = 'Select to end of line' })
vim.keymap.set('v', 'L', '$h', { desc = 'Select to end of line' })
vim.keymap.set('n', 'H', 'v^', { desc = 'Select to start of line' })
vim.keymap.set('v', 'H', '^', { desc = 'Select to start of line' })

-- Search and replace the word under the cursor
vim.keymap.set('n', '<Leader>/r', [[:%s/<C-r><C-w>//g<Left><Left>]], { desc = '[S]earch and [R]eplace the word under the cursor' })
-- Search whole word
vim.keymap.set('n', '<Leader>/w', '/\\<\\><Left><Left>', { desc = '[/] Search [W]hole word' })
-- Search current
vim.keymap.set({ 'n', 'v' }, '*', '*N', { desc = 'Search current' })
vim.keymap.set({ 'n', 'v' }, '#', '#n', { desc = 'Search current' })
-- Like "*/#", but don't put "\<" and "\>" around the word
vim.keymap.set({ 'n', 'v' }, 'g*', 'g*N', { desc = 'Search current' })
vim.keymap.set({ 'n', 'v' }, 'g#', 'g#n', { desc = 'Search current' })

-- Copy File Name/Path to unamed register - p to paste
vim.keymap.set('n', '<Leader>cf', '<cmd>let @" = expand("%")<CR>', { desc = '[C]opy [F]ile' })
vim.keymap.set('n', '<Leader>cp', '<cmd>let @" = expand("%:p")<CR>', { desc = '[C]opy [P]ath' })

-- nvim: [P]aste over visual selection without losing yanked lines
-- See `:help put-Visual-mode`
-- Delete/change selection without losing yanked lines
vim.keymap.set('v', 'D', [["_d]], { desc = 'Delete into Black hole register' })
vim.keymap.set('n', 'dD', [["_dd]], { desc = 'Delete into Black hole register' })
vim.keymap.set('v', 'C', [["_c]], { desc = 'Delete into Black hole register' })
vim.keymap.set('n', 'cC', [["_cc]], { desc = 'Delete into Black hole register' })

-- Insert tab space in normal mode
vim.keymap.set('n', '<Tab>', 'i<Tab><Esc>', { desc = 'Insert tab space in normal mode' })

-- Comment string
vim.keymap.set('n', 'gcn', 'ONOTE: <Esc>gccA', { desc = 'NOTE Comment insert above', remap = true })
vim.keymap.set('n', 'gct', 'OTODO: <Esc>gccA', { desc = 'TODO Comment insert above', remap = true })

-- Quickly edit your macros
-- https://github.com/mhinz/vim-galore?tab=readme-ov-file#quickly-edit-your-macros
-- This is a real gem! The mapping takes a register (or `*` by default) and opens it in the cmdline-window.
-- Hit `<cr>` when you're done editing for setting the register.
-- Use it like this `<leader>m` or `"q<leader>m`.
vim.keymap.set('n', '<Leader>m', [[:<c-u><c-r><c-r>='let @'. v:register .' = '. string(getreg(v:register))<cr><c-f><left>]], { desc = 'Edit [M]acros' })

local M = require('config.functions')
-- Open git blame commit URL
vim.keymap.set('n', vim.g.option_toggle_prefix .. 'c', M.gitBlameOpenCommitURL, { desc = 'Open Git Commit URL' })
vim.keymap.set('n', vim.g.option_toggle_prefix .. 'f', M.gitBlameOpenCommitFileURL, { desc = 'Open Git Commit File URL' })

-- Custom toggles
-- Toggle line number
vim.keymap.set({ 'n', 'v' }, vim.g.option_toggle_prefix .. 'n', '<cmd>set nonu! nornu!<CR>', { desc = "Toggle 'nu' & 'rnu'" })
-- Toggle virtual edit mode between onemore and all
vim.keymap.set({ 'n', 'v' }, vim.g.option_toggle_prefix .. 'v', M.toggleVirtualEdit, { desc = "Toggle 'virtualedit'" })
-- Toggle clipboard between unnamedplus and none
vim.keymap.set({ 'n', 'v' }, vim.g.option_toggle_prefix .. 'p', M.toggleClipboard, { desc = "Toggle 'clipboard'" })
-- Toggle signcolumn
vim.keymap.set({ 'n', 'v' }, vim.g.option_toggle_prefix .. 's', M.toggleSigncolumn, { desc = "Toggle 'signcolumn'" })
-- Toggle vim keyword
vim.keymap.set({ 'n', 'v' }, vim.g.option_toggle_prefix .. 'W', M.toggleKeyword, { desc = "Toggle 'iskeyword'" })
-- Toggle Zen mode
vim.keymap.set({ 'n', 'v' }, vim.g.option_toggle_prefix .. 'z', M.toggleZenMode, { desc = "Toggle Zen Mode" })
-- Remove trailing blank lines at the end of file
vim.keymap.set('n', '<Leader>fe', M.trimEndLines, { desc = '[F]ormat [E]nd of file', silent = true })

-- Toggle alternate-file or last edited file
vim.keymap.set({ 'n', 'v' }, '<Leader>.', M.altFileOrOldFile, { desc = 'Toggle last file ("." for repeat)', silent = true })

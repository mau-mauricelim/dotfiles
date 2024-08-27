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
vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

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
-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
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
vim.keymap.set('n', '<Leader>gs', 'guiwv~', { desc = '[S]entence case word' })

-- Visual block mode (Default Ctrl-V)
-- Ctrl-V is bound to paste in Windows Terminal, use Ctrl-Q instead
-- Shift-V for visual line mode
vim.keymap.set('n', '<Leader>vb', '<C-v>', { desc = '[V]isual [B]lock mode' })

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
vim.keymap.set('n', '<Leader>si', 'yyP^d$a-- stylua: ignore<Esc>', { desc = 'Add [S]tylua [I]gnore above current line' })

-- Change all
vim.keymap.set('n', 'cA', 'ggdGi', { desc = '[C]hange [A]ll lines' })
-- Yank all
vim.keymap.set('n', 'yA', '<cmd>%y<CR>', { desc = '[Y]ank [A]ll lines', silent = true })
-- Select to end of line: similar to `C`, `D` and `Y`
vim.keymap.set('n', 'L', 'v$h', { desc = 'Select to end of line' })
vim.keymap.set('n', 'H', 'v^', { desc = 'Select to start of line' })
-- Select pasted text: similar to `gv`
vim.keymap.set('n', 'gp', [['`[' . strpart(getregtype(), 0, 1) . '`]']], { expr = true, desc = 'Select previous pasted text' })

-- Search and replace the word under the cursor
vim.keymap.set('n', '<Leader>/r', [[:%s/<C-r><C-w>//g<Left><Left>]], { desc = '[S]earch and [R]eplace the word under the cursor' })
-- Search whole word
vim.keymap.set('n', '<Leader>/w', '/\\<\\><Left><Left>', { desc = '[/] Search [W]hole word' })

-- Copy File Name/Path to unamed register - p to paste
vim.keymap.set('n', '<Leader>cf', '<cmd>let @" = expand("%")<CR>', { desc = '[C]opy [F]ile' })
vim.keymap.set('n', '<Leader>cp', '<cmd>let @" = expand("%:p")<CR>', { desc = '[C]opy [P]ath' })

-- nvim: [P]aste over visual selection without losing yanked lines
-- See `:help put-Visual-mode`

-- Delete selection without losing yanked lines
vim.keymap.set({ 'n', 'v' }, '<Leader>dv', [["_d]], { desc = '[D]elete into [V]oid register' })
-- Yank to/Paste from system clipboard
vim.keymap.set('n', '<Leader>Y', [["+Y]], { desc = 'Yank to end of line to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<Leader>y', [["+y]], { desc = 'Yank to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<Leader>pp', [["+p]], { desc = 'Paste from system clipboard' })
-- Insert line below/above current line without leaving normal mode
vim.keymap.set('n', '<Leader>o', 'o<Esc>', { desc = 'Insert line below without leaving normal mode' })
vim.keymap.set('n', '<Leader>O', 'O<Esc>', { desc = 'Insert line above without leaving normal mode' })

-- Insert tab space in normal mode
vim.keymap.set('n', '<Tab>', 'i<Tab><Esc>', { desc = 'Insert tab space in normal mode' })

local M = require('config.functions')
-- Open git blame commit URL
vim.keymap.set('n', '<Leader>bc', M.GitBlameOpenCommitURL, { desc = 'Open Git [B]lame [C]ommit URL' })
vim.keymap.set('n', '<Leader>bf', M.GitBlameOpenCommitFileURL, { desc = 'Open Git [B]lame [F]ile URL' })

-- Custom toggles
-- Toggle line number
vim.keymap.set('n', '<Leader>tn', '<cmd>set nonu! nornu!<CR>', { desc = '[T]oggle line [N]umber' })
-- Toggle virtual edit mode between onemore and all
vim.keymap.set( 'n', '<Leader>ve', M.toggleVirtualEdit, { desc = 'Toggle [V]irtual[E]dit mode between onemore and all' })
-- Toggle clipboard between unnamedplus and none
vim.keymap.set({ 'n', 'v' }, '<Leader>cb', M.toggleClipboard, { desc = 'Toggle [C]lip[b]oard' })
-- Toggle signcolumn
vim.keymap.set('n', '<Leader>tc', M.toggleSigncolumn, { desc = '[T]oggle sign[C]olumn' })
-- Toggle vim keyword
vim.keymap.set('n', '<Leader>tw', M.toggleKeyword, { desc = '[T]oggle vim key[w]ord' })
-- Remove trailing blank lines at the end of file
vim.keymap.set('n', '<Leader>fe', M.trimEndLines, { desc = '[F]ormat [E]nd of file', silent = true })
-- Toggle Zen mode
vim.keymap.set('n', '<Leader>tz', M.toggleZenMode, { desc = '[T]oggle [Z]en mode' })

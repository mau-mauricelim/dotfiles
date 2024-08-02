-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, for help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'
vim.opt.mousemodel = 'extend'

-- Don't show the mode, since it's already in status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- Use <Leader>cb to toggle unnamedplus clipboard
-- vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
-- vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true
vim.opt.undolevels = 100000
vim.opt.undoreload = 100000

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'
--- Set colorcolumn
-- vim.opt.colorcolumn = '120'

-- Decrease update time
vim.opt.updatetime = 100
-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
-- vim.opt.scrolloff = 10

-- Show existing tab with 4 spaces width
vim.opt.tabstop = 4
-- When indenting with '>', use 4 spaces width
vim.opt.shiftwidth = 4
-- On pressing tab, insert 4 spaces
vim.opt.expandtab = true
-- No wrap
vim.opt.wrap = false
-- Allow the cursor to move just past the end of the line
vim.opt.virtualedit = 'onemore'

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- List of all commands for each mode
-- :h index

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

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
-- Center search and open folds for this line
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

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
vim.keymap.set({ 'n', 'v' }, '<Home>', 'charcol(".") ==  1 ? "^" : "0"', { expr = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '0', 'charcol(".") ==  1 ? "^" : "0"', { expr = true, silent = true })
vim.keymap.set('i', '<Home>', 'charcol(".") ==  1 ? "<Esc>^i" : "<Esc>0i"', { expr = true, silent = true })
vim.keymap.set('n', '<End>', 'charcol(".") == charcol("$")-1 ? "g_" : "$"', { expr = true, silent = true })
vim.keymap.set('v', '<End>', 'charcol(".") == charcol("$") ? "g_" : "$"', { expr = true, silent = true })
vim.keymap.set('i', '<End>', 'charcol(".") == charcol("$")-1 ? "<Esc>g_a" : "<Esc>$a"', { expr = true, silent = true })
-- If EOL, then join, else del char
vim.keymap.set('n', 'x', 'charcol(".") == charcol("$") ? "J" : "x"', { expr = true, silent = true })

-- Save file
vim.keymap.set({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><Esc>', { desc = 'Save file' })
-- Disable go to sleep keymap
vim.keymap.set('n', 'gs', '<nop>')

-- Indenting to remain in visual mode
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Toggle line number
vim.keymap.set('n', '<Leader>tn', '<cmd>set nonu! nornu!<CR>', { desc = '[T]oggle line [N]umber' })

-- Sentence case word
vim.keymap.set('n', '<Leader>gs', 'guiwv~', { desc = '[S]entence case word' })

-- Visual block mode (Default Ctrl-V)
-- Ctrl-V is bound to paste in Windows Terminal, use Ctrl-Q instead
-- Shift-V for visual line mode
vim.keymap.set('n', '<Leader>vb', '<C-v>', { desc = '[V]isual [B]lock mode' })

-- Vertical split and move
vim.keymap.set('n', '<Leader>vs', '<cmd>vsp<CR><C-w><C-p><cmd>bp<CR><C-w><C-p>', { desc = '[V]ertical [S]plit and move' })

-- Execute vim and lua (print) commands
-- stylua: ignore
function P(v) print(vim.inspect(v)); return v end
vim.keymap.set('n', '<Leader>lu', ':lua ', { desc = 'Run [Lu]a command' })
vim.keymap.set('n', '<Leader>lp', ':lua P()<Left>', { desc = 'Run [L]ua [P]rint command' })
vim.keymap.set('n', '<Leader>xv', '<cmd>exec getline(".")<CR>', { desc = 'E[X]ecute current line in Vim' })
vim.keymap.set('n', '<Leader>xl', '<cmd>exec "lua ".getline(".")<CR>', { desc = 'E[X]ecute current line in Lua' })
vim.keymap.set('n', '<Leader>xp', '<cmd>exec "lua P(".getline(".").")"<CR>', { desc = 'E[X]ecute current line in Lua print()' })

-- Add -- stylua: ignore above current line
vim.keymap.set('n', '<Leader>si', 'yyP^d$a-- stylua: ignore<Esc>', { desc = 'Add [S]tylua [I]gnore above current line' })

-- Change all
vim.keymap.set('n', 'cA', 'ggdGi', { desc = '[C]hange [A]ll lines' })

-- Search and replace the word under the cursor
vim.keymap.set('n', '<Leader>/r', [[:%s/<C-r><C-w>//g<Left><Left>]], { desc = '[S]earch and [R]eplace the word under the cursor' })
-- Search whole word
vim.keymap.set('n', '<Leader>/w', '/\\<\\><Left><Left>', { desc = '[/] Search [W]hole word' })
-- HINT: Search for visual selection with *

-- Copy File Name/Path to unamed register - p to paste
vim.keymap.set('n', '<Leader>cf', '<cmd>let @" = expand("%")<CR>', { desc = '[C]opy [F]ile' })
vim.keymap.set('n', '<Leader>cp', '<cmd>let @" = expand("%:p")<CR>', { desc = '[C]opy [P]ath' })

-- nvim: [P]aste over visual selection without losing yanked lines
-- See `:help put-Visual-mode`

-- Delete selection without losing yanked lines
vim.keymap.set({'n', 'v'}, '<Leader>dv', [["_d]], { desc = '[D]elete into [V]oid register' })
-- Yank to/Paste from system clipboard
vim.keymap.set('n', '<Leader>Y', [["+Y]], { desc = 'Yank to end of line to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<Leader>y', [["+y]], { desc = 'Yank to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<Leader>pp', [["+p]], { desc = 'Paste from system clipboard' })
-- Insert line below/above current line without leaving normal mode
vim.keymap.set('n', '<Leader>o', 'o<Esc>', { desc = 'Insert line below without leaving normal mode' })
vim.keymap.set('n', '<Leader>O', 'O<Esc>', { desc = 'Insert line above without leaving normal mode' })

-- Insert tab space in normal mode
vim.keymap.set('n', '<Tab>', 'i<Tab><Esc>', { desc = 'Insert tab space in normal mode' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Disable auto comment new lines
vim.api.nvim_create_autocmd('BufEnter', {
  desc = 'Disable auto comment new lines',
  command = 'set fo-=c fo-=r fo-=o'
})

-- Center screen
vim.api.nvim_create_autocmd('BufReadPre', {
  desc = 'Center screen',
  callback = function()
    vim.api.nvim_feedkeys('zz', 'n', true)
  end
})

-- Add new filetype mappings
vim.filetype.add({ extension = { q = 'q', k = 'k' }})

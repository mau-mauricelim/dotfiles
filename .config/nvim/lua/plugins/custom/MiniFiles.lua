-- Navigate and manipulate file system
local MiniFiles = require('mini.files')
-- MiniFiles.open                                                                                -- Open current working directory in a last used state
MiniFiles.open_fresh = function() MiniFiles.open(nil, false) end                                 -- Fresh explorer in current working directory
MiniFiles.open_parent_resume = function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end       -- Open directory of current file (in last used state) focused on the file
MiniFiles.open_parent_fresh = function() MiniFiles.open(vim.api.nvim_buf_get_name(0), false) end -- Fresh explorer in directory of current file
MiniFiles.setup({
  -- Module mappings created only inside explorer.
  -- Use `''` (empty string) to not create one.
  --- - With default mappings for `h` / `l` it might be not convenient to rename
  ---   only part of an entry. You can adopt any of the following approaches:
  ---     - Use different motions, like |$|, |e|, |f|, etc.
  ---     - Go into Insert mode and navigate inside it.
  ---     - Change mappings to be more suited for manipulation and not navigation.
  ---       See "Mappings" section in |MiniFiles.config|.
  mappings = {
    close       = 'q', -- '<C-c>'
    go_in       = '',  -- Replaced with go_in_if_dir
    go_in_plus  = 'L', -- '<CR>'
    go_out      = 'h',
    go_out_plus = 'H', -- '-'
    mark_goto   = "'",
    mark_set    = 'm',
    reset       = '<BS>',
    reveal_cwd  = '@',
    show_help   = 'g?',
    synchronize = '<C-s>',
    trim_left   = '<',
    trim_right  = '>',
  },
  -- Customization of explorer windows
  windows = {
    -- Maximum number of windows to show side by side
    max_number = math.huge,
    -- Whether to show preview of file/directory under cursor
    preview = true,
    -- Width of focused window
    width_focus = 20,
    -- Width of non-focused window
    width_nofocus = 15,
    -- Width of preview window
    width_preview = math.floor(tonumber(vim.api.nvim_exec2("echo &columns", { output = true }).output)/2) or 70,
  },
})
-- Similar to oil.nvim
vim.keymap.set('n', '-', MiniFiles.open_parent_fresh, { desc = 'Fresh explorer in directory of current file' })
vim.keymap.set('n', '_', MiniFiles.open, { desc = 'Open current working directory in a last used state' })

-- Create mapping to show/hide dot-files
local show_dotfiles = true
local filter_show = function() return true end
local filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, '.') end
local toggle_dotfiles = function()
  show_dotfiles = not show_dotfiles
  local new_filter = show_dotfiles and filter_show or filter_hide
  MiniFiles.refresh({ content = { filter = new_filter } })
end
-- Create mapping to set current working directory
local files_set_cwd = function()
  -- Works only if cursor is on the valid file system entry
  local cur_entry_path = MiniFiles.get_fs_entry().path
  local cur_directory = vim.fs.dirname(cur_entry_path)
  vim.fn.chdir(cur_directory)
end
-- Create mapping to go in if entry is a directory (I.E. do not open buffer if entry is a file)
local go_in_if_dir = function()
  if (MiniFiles.get_fs_entry() or {}).fs_type ~= 'directory' then return end
  MiniFiles.go_in()
end
vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    local buf_id = args.data.buf_id
    -- Tweak left-hand side of mapping to your liking
    vim.keymap.set('n', 'g.', toggle_dotfiles, { buffer = buf_id })
    vim.keymap.set('n', 'g~', files_set_cwd, { buffer = buf_id })
    vim.keymap.set('n', 'l', go_in_if_dir, { buffer = args.data.buf_id })
  end,
})

-- Set custom bookmarks
vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesExplorerOpen',
  callback = function()
    MiniFiles.set_bookmark('n', vim.fn.stdpath('config'), { desc = 'Config' }) -- path
    MiniFiles.set_bookmark('w', vim.fn.getcwd, { desc = 'Working directory' }) -- callable
    MiniFiles.set_bookmark('~', '~', { desc = 'Home directory' })
  end,
})

-- Create mapping to toggle preview
local show_preview = MiniFiles.config.windows.preview
local vert_move = function(is_top) return is_top and 'j' or 'k' end
local toggle_preview = function()
  show_preview = not show_preview
  MiniFiles.refresh({ windows = { preview = show_preview } })
  -- HACK: to force window to refresh, does not work with single dir/file items
  local is_top = vim.api.nvim_win_get_cursor(0)[1] == 1
  local first_move = vert_move(is_top)
  local last_move = vert_move(not is_top)
  vim.api.nvim_feedkeys(first_move, 'n', false)
  vim.defer_fn(function() vim.api.nvim_feedkeys(last_move, 'n', false) end, 0)
end
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'minifiles' },
  callback = function()
    -- vim.keymap.set('n', '-', MiniFiles.go_out, { buffer = true })
    vim.keymap.set('n', '-', function() MiniFiles.go_out() MiniFiles.trim_right() end, { buffer = true })
    vim.keymap.set('n', '<CR>', function() MiniFiles.go_in({ close_on_file = true }) end, { buffer = true })
    vim.keymap.set('n', '<C-p>', toggle_preview, { buffer = true })
  end,
})

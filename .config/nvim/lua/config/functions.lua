-- Custom functions (module)
-- stylua: ignore start
local M = {}

-- Print lua commands
function P(v) print(vim.inspect(v)); return v end

-- Set vim option and notify
function SetVimOpt(option, value)
  vim.opt[option] = value
  vim.notify(option .. '="' .. value .. '"')
end

-- Toggle virtual edit mode between onemore and all
function M.toggleVirtualEdit() SetVimOpt('virtualedit', vim.o.virtualedit == 'onemore' and 'all' or 'onemore') end

-- Toggle clipboard between none, unnamed and unnamedplus
function M.toggleClipboard() SetVimOpt('clipboard', vim.o.clipboard == '' and 'unnamed' or (vim.o.clipboard == 'unnamed' and 'unnamedplus' or '')) end

-- Toggle signcolumn
function M.toggleSigncolumn() SetVimOpt('signcolumn', vim.o.signcolumn == 'yes' and 'no' or 'yes') end

-- Toggle vim keyword
function M.toggleKeyword()
  vim.ui.input({ prompt = '(Toggle vim keyword) Enter keyword: '}, function(input)
    if input == nil then return nil end
    -- Remove whitespaces
    input = input:gsub('%s+', '')
    -- TODO: Apply a unique function on string input
    if input == '' then return nil end

    -- Loop through each character
    for i = 1, #input do
      local keyword = vim.o.iskeyword
      local char = input:sub(i, i)
      vim.cmd('set iskeyword+=' .. char)
      -- If unchanged
      if keyword == vim.o.iskeyword then
        vim.cmd('set iskeyword-=' .. char)
        vim.notify('Removed ' .. char .. ' from vim keyword')
      else
        vim.notify('Appended ' .. char .. ' to vim keyword')
      end
    end
  end)
end

-- Remove trailing blank lines at the end of file
function M.trimEndLines()
  local cursor_pos = vim.fn.getpos('.')
  vim.notify('Removing trailing blank lines at the end of file')
  -- Note that this removes all trailing lines that contain only whitespace.
  -- To remove only truly "empty" lines, remove the \s* from the below command.
  vim.cmd('silent! %s#\\($\\n\\s*\\)\\+\\%$##')
  vim.fn.setpos('.', cursor_pos)
end

-- Toggle Zen mode
vim.g.zen_mode = false
function M.toggleZenMode()
  vim.o.signcolumn = vim.g.zen_mode and 'yes' or 'no'
  vim.o.nu = vim.g.zen_mode
  vim.o.rnu = vim.g.zen_mode
  vim.g.miniindentscope_disable = not vim.g.zen_mode
  local status_ok, ibl = pcall(require, 'ibl')
  if status_ok then
    ibl.update({ enabled = vim.g.zen_mode })
  end
  vim.g.zen_mode = not vim.g.zen_mode
end

-- Open URL in browser
function M.browse(url)
  local _, res = pcall(vim.ui.open, url)
  if res == nil then
    -- HACK: WSL
    vim.fn.systemlist('uname -a|grep -iq wsl && cmd.exe /c start ' .. url)
  end
end

function M.getLineNumber() return vim.api.nvim_win_get_cursor(0)[1] end
function M.getFilePath() return vim.fn.shellescape(vim.fn.expand('%:p')) end
function M.getFileDir() return vim.fn.shellescape(vim.fn.expand('%:p:h')) end

-- Open git blame commit URL
function M.gitBlameOpenCommitURL()
  local line_number = M.getLineNumber()
  local filepath = M.getFilePath()
  local git_dir = M.getFileDir()
  local cmd = 'cd ' .. git_dir .. ' && ' ..
    'HASH=$(git blame -pl -L ' .. line_number .. ',' .. line_number .. ' ' .. filepath .. '|head -1|cut -d" " -f1);' ..
    [[ [ -n "$HASH" ] && [ "$HASH" != "0000000000000000000000000000000000000000" ] &&
      echo $(git config --get remote.origin.url|sed -e 's/\.com:/.com\//g ; s/\.net:/.net\//g ; s/^git@/https:\/\//g ; s/\.git$//g')/commit/$HASH ]]
  local commit_url = vim.fn.systemlist(cmd)[2]
  if commit_url ~= nil then
    vim.notify('Opening ' .. commit_url)
    M.browse(commit_url)
  else
    vim.notify('Not Commited Yet')
  end
end

-- Open git blame commit file URL
function M.gitBlameOpenCommitFileURL()
  local line_number = M.getLineNumber()
  local filepath = M.getFilePath()
  local git_dir = M.getFileDir()
  local cmd = 'cd ' .. git_dir .. ' && ' ..
    'HASH=$(git blame -pl -L ' .. line_number .. ',' .. line_number .. ' ' .. filepath .. '|head -1|cut -d" " -f1);' ..
    -- Path has `/` so use a different `|` separator
    'RELPATH_GITROOT=$(readlink -f ' .. filepath .. '|sed "s|^$(git rev-parse --show-toplevel)||g");' ..
    [[
      [ -n "$HASH" ] && [ "$HASH" != "0000000000000000000000000000000000000000" ] &&
      [ -n "$RELPATH_GITROOT" ] &&
      echo $(git config --get remote.origin.url|sed -e 's/\.com:/.com\//g ; s/\.net:/.net\//g ; s/^git@/https:\/\//g ; s/\.git$//g')/blob/$HASH/$RELPATH_GITROOT
      ]]
  local commit_url = vim.fn.systemlist(cmd)[2]
  if commit_url ~= nil then
    vim.notify('Opening ' .. commit_url)
    M.browse(commit_url)
  else
    vim.notify('Not Commited Yet')
  end
end

-- alternate-file or last edited file
-- `CTRL-^` for alternate-file
-- `'0` for last edited file
-- BUG: sometimes does not work when opening last edited file
function M.altFileOrOldFile()
  local status_ok, _ = pcall(vim.cmd, 'e#')
  if not status_ok then
    vim.cmd([[norm '0]])
    local current_buf_name = vim.api.nvim_buf_get_name(0)
    vim.cmd('bp')
    local prev_current_buf_name = vim.api.nvim_buf_get_name(0)
    if prev_current_buf_name == '' then
      vim.cmd('bd')
    elseif current_buf_name == prev_current_buf_name then
      vim.cmd('e#<2')
    end
  end
end

-- Send lines to adjacent tmux pane
function _G.sendLinesToTmuxPane()
  -- Determine the current mode
  local mode = vim.fn.mode()
  local text
  if mode == 'V' or mode == 'v' or mode == '' then
    -- Visual mode: get the selected text
    -- Save the current visual selection
    vim.cmd('normal! "vy')
    text = vim.fn.getreg('v')
  elseif mode == 'n' then
    -- Normal mode: get the current line
    text = vim.fn.getline('.')
  else
    return nil
  end
  -- HACK: Add white space before '--*'
  text = text:gsub('^%s*%-%-', ' --')
  -- Escape special characters and send to tmux
  local escaped_text = text:gsub('([;"$`\\])', '\\%1')
  vim.fn.system('tmux send-keys -t .+ "' .. escaped_text .. '" Enter')
end

return M

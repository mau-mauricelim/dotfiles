-- Custom functions (module)
-- stylua: ignore start
local M = {}

-- Print lua commands
function P(v) print(vim.inspect(v)); return v end

-- Set vim option and notify
function SetVimOpt(option, value)
  vim.opt[option] = value
  vim.notify(option..'="'..value..'"')
end

-- Toggle virtual edit mode between onemore and all
function M.toggleVirtualEdit() SetVimOpt('virtualedit', vim.o.virtualedit == 'onemore' and 'all' or 'onemore') end

-- Toggle clipboard between unnamedplus and none
function M.toggleClipboard() SetVimOpt('clipboard', vim.o.clipboard == '' and 'unnamedplus' or '') end

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
function M.Browse(url)
  local _, res = pcall(vim.ui.open, url)
  if res == nil then
    -- HACK: WSL
    vim.fn.systemlist('uname -a|grep -iq wsl && cmd.exe /c start ' .. url)
  end
end

function M.GetLineNumber() return vim.api.nvim_win_get_cursor(0)[1] end
function M.GetFilePath() return vim.fn.shellescape(vim.fn.expand('%:p')) end
function M.GetFileDir() return vim.fn.shellescape(vim.fn.expand('%:p:h')) end

-- Open git blame commit URL
function M.GitBlameOpenCommitURL()
  local line_number = M.GetLineNumber()
  local filepath = M.GetFilePath()
  local git_dir = M.GetFileDir()
  local cmd = 'cd ' .. git_dir .. ' && ' ..
    'HASH=$(git blame -pl -L ' .. line_number .. ',' .. line_number .. ' ' .. filepath .. '|head -1|cut -d" " -f1);' ..
    [[ [ -n "$HASH" ] && [ "$HASH" != "0000000000000000000000000000000000000000" ] &&
      echo $(git config --get remote.origin.url|sed -e 's/\.com:/.com\//g ; s/\.net:/.net\//g ; s/^git@/https:\/\//g ; s/\.git$//g')/commit/$HASH ]]
  local commit_url = vim.fn.systemlist(cmd)[1]
  if commit_url ~= nil then
    vim.notify('Opening ' .. commit_url)
    M.Browse(commit_url)
  else
    vim.notify('Not Commited Yet')
  end
end

-- Open git blame commit file URL
function M.GitBlameOpenCommitFileURL()
  local line_number = M.GetLineNumber()
  local filepath = M.GetFilePath()
  local git_dir = M.GetFileDir()
  local cmd = 'cd ' .. git_dir .. ' && ' ..
    'HASH=$(git blame -pl -L ' .. line_number .. ',' .. line_number .. ' ' .. filepath .. '|head -1|cut -d" " -f1);' ..
    -- Path has `/` so use a different `|` separator
    'RELPATH_GITROOT=$(readlink -f ' .. filepath .. '|sed "s|^$(git rev-parse --show-toplevel)||g");' ..
    [[
      [ -n "$HASH" ] && [ "$HASH" != "0000000000000000000000000000000000000000" ] &&
      [ -n "$RELPATH_GITROOT" ] &&
      echo $(git config --get remote.origin.url|sed -e 's/\.com:/.com\//g ; s/\.net:/.net\//g ; s/^git@/https:\/\//g ; s/\.git$//g')/blob/$HASH/$RELPATH_GITROOT
      ]]
  local commit_url = vim.fn.systemlist(cmd)[1]
  if commit_url ~= nil then
    vim.notify('Opening ' .. commit_url)
    M.Browse(commit_url)
  else
    vim.notify('Not Commited Yet')
  end
end

return M

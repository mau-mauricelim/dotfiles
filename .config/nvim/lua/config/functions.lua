-- Custom functions (module)
-- stylua: ignore start
local M = {}

function IsMusl() return vim.loop.fs_stat('/lib/ld-musl-x86_64.so.1') ~= nil end

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
function M.altFileOrOldFile()
  local status_ok, _ = pcall(vim.cmd, 'e#')
  if not status_ok then
    -- No alternate file, try oldfiles
    local oldfiles = vim.v.oldfiles
    local current_file = vim.api.nvim_buf_get_name(0)
    -- Find first oldfile that's not the current file
    for _, old_file in ipairs(oldfiles) do
      if old_file ~= current_file and vim.fn.filereadable(old_file) == 1 then
        vim.cmd('edit ' .. vim.fn.fnameescape(old_file))
        return
      end
    end
    -- If no oldfile found, just notify
    vim.notify('No previous file to open', vim.log.levels.INFO)
  end
end

-- Send lines to adjacent tmux pane
function _G.sendLinesToTmuxPane(mode, output)
  local text
  if mode == 'visual' then
    text = vim.fn.getreg('v')
  else
    text = vim.fn.getline('.')
  end

  local lines = {}
  local comment_pattern = vim.bo.commentstring:gsub('%%s.*', ''):gsub('%p', '%%%1')
  for line in text:gmatch("[^\n]+") do
    -- Skip comment line if output is one-line
    if output == 'one-line' then
      if line:match('^%s*' .. comment_pattern) then
        goto continue
      end
    end
    -- HACK: Add white space before '-*' and after ';'
    line = line:gsub('^%s*%-', ' -')
    line = line:gsub(';$', '; ')
    table.insert(lines, line)
    ::continue::
  end

  if output == 'one-line' then
    text = table.concat(lines)
  else
    text = table.concat(lines, '\n')
  end

  -- Send Escape first to exit any mode, then clear line with Ctrl-C
  vim.fn.system('tmux send-keys -t .+ Escape C-c')

  -- Escape special characters and send to tmux
  local escaped_text = text:gsub('(["$`\\])', '\\%1')
  vim.fn.system('tmux send-keys -t .+ "' .. escaped_text .. '" Enter')
end

return M

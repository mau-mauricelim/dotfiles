-- Custom functions

-- Toggle virtual edit mode between onemore and all
vim.keymap.set(
  'n',
  '<Leader>ve',
  function()
    if vim.o.virtualedit == 'onemore' then
      vim.notify('virtualedit="all"')
      vim.opt.virtualedit = 'all'
    else
      vim.notify('virtualedit="onemore"')
      vim.opt.virtualedit = 'onemore'
    end
  end,
  -- Since Lua function don't have a useful string representation, you can use the "desc" option to document your mapping
  { desc = 'Toggle [V]irtual[E]dit mode between onemore and all' }
)

-- Toggle vim keyword
vim.keymap.set('n', '<Leader>tw', function()
  local keyword = vim.o.iskeyword
  if string.find(keyword, '.', 1, true) == nil then
    vim.opt.iskeyword:append('.')
  else
    vim.opt.iskeyword:remove('.')
  end
end, { desc = '[T]oggle vim key[w]ord' })

-- Toggle unnamedplus clipboard
vim.keymap.set('n', '<Leader>cb', function()
  if vim.o.clipboard == '' then
    vim.notify('clipboard="unnamedplus"')
    vim.opt.clipboard = 'unnamedplus'
  else
    vim.notify('clipboard=""')
    vim.opt.clipboard = ''
  end
end, { desc = 'Toggle unnamedplus [C]lip[b]oard' })

-- Remove trailing blank lines at the end of file
function TrimEndLines()
  local cursor_pos = vim.fn.getpos('.')
  vim.notify('Removing trailing blank lines at the end of file')
  -- Note that this removes all trailing lines that contain only whitespace.
  -- To remove only truly "empty" lines, remove the \s* from the below command.
  vim.cmd('silent! %s#\\($\\n\\s*\\)\\+\\%$##')
  vim.fn.setpos('.', cursor_pos)
end
vim.keymap.set('n', '<Leader>fe', TrimEndLines, { desc = '[F]ormat [E]nd of file', silent = true })

-- Remove [No Name] and directory buffers
local function IsNoNameBuffer(buf)
  return vim.api.nvim_buf_is_loaded(buf)
    and vim.api.nvim_get_option_value('buflisted', buf)
    and vim.api.nvim_buf_get_name(buf) == ''
    and vim.api.nvim_get_option_value('buflisted', buf) == ''
    and vim.api.nvim_get_option_value('buflisted', buf) == ''
end
function ClearBuffers()
  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    if IsNoNameBuffer(buf) or vim.fn.isdirectory(vim.api.nvim_buf_get_name(buf)) == 1 then
      vim.cmd('bw ' .. buf)
    end
  end
end

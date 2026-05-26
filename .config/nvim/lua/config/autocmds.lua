-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Disable auto comment new lines
vim.api.nvim_create_autocmd('BufEnter', {
  desc = 'Disable auto comment new lines',
  command = 'set fo-=c fo-=r fo-=o',
})

-- Center screen
vim.api.nvim_create_autocmd('BufReadPre', {
  desc = 'Center screen',
  callback = function()
    vim.api.nvim_feedkeys('zz', 'n', true)
  end,
})

-- Add new filetype mappings
vim.filetype.add({ extension = { q = 'q', k = 'k' } })

-- https://www.lazyvim.org/configuration/general#auto-commands
local function augroup(name)
  return vim.api.nvim_create_augroup('lazyvim_' .. name, { clear = true })
end

-- Go to last location when opening a buffer
vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup('last_loc'),
  callback = function(event)
    local exclude = { 'gitcommit' }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd('FileType', {
  group = augroup('close_with_q'),
  pattern = {
    'PlenaryTestPopup',
    'grug-far',
    'help',
    'lspinfo',
    'notify',
    'qf',
    'spectre_panel',
    'startuptime',
    'tsplayground',
    'neotest-output',
    'checkhealth',
    'neotest-summary',
    'neotest-output-panel',
    'dbout',
    'gitsigns-blame',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<CR>', {
      buffer = event.buf,
      silent = true,
      desc = 'Quit buffer',
    })
  end,
})

vim.api.nvim_create_autocmd({ 'TermOpen', 'BufEnter' }, {
  group = vim.api.nvim_create_augroup('TerminalBehavior', { clear = true }),
  pattern = 'term://*',
  callback = function()
    -- If in kitty scrollback
    if vim.fn.getenv('KITTY_SCROLLBACK') == '1' then
      local opts = { buffer = true, silent = true }
      -- Disable keymaps into insert/terminal mode or modify buffer
      local disable = {
        '<', '>', '=', '~', '<C-a>', '<C-x>',
        'a', 'A', 'c', 'C', 'i', 'I', 'o', 'O',
        'd', 'D', 'J', 'p', 'P', 'r', 'R', 's', 'x', 'X',
      }
      for _, key in ipairs(disable) do
        vim.keymap.set('n', key, '<Nop>', opts)
      end
      -- Disable kj escape for faster movement
      vim.keymap.set('n', 'k', 'kzz', opts)
      -- Last non-empty line
      local last_line = 1
      vim.defer_fn(function()
        local buf = vim.api.nvim_get_current_buf()
        local count = vim.api.nvim_buf_line_count(buf)
        for i = count, 1, -1 do
          local line = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
          if line and line:match('%S') then
            last_line = i
            break
          end
        end
        -- Go to last non-empty line
        vim.api.nvim_win_set_cursor(0, { last_line, 0 })
      end, 100)
      local function clamp(keys)
        local lower_keys = keys:lower()
        local mouse = lower_keys:find("mouse") ~= nil and lower_keys:find("scroll") ~= nil
        -- Get current column before movement
        local col = vim.api.nvim_win_get_cursor(0)[2]
        local t = vim.api.nvim_replace_termcodes(keys, true, false, true)
        return function()
          vim.api.nvim_feedkeys(t, 'nx', false)
          local row = vim.api.nvim_win_get_cursor(0)[1]
          if row > last_line then
            vim.api.nvim_win_set_cursor(0, { last_line, col })
          end
          -- Center screen on current line
          if not mouse then
            vim.cmd.normal({ 'zz', bang = true })
          end
        end
      end
      -- Clamp keys to last non-empty line
      local clamps = {
        'G', 'j', '<Down>', '<C-d>', '<PageDown>',
        'w', 'W', 'e', 'E',
        '<LeftMouse>', '<2-LeftMouse>', '<RightMouse>', '<ScrollWheelDown>',
      }
      for _, key in ipairs(clamps) do
        vim.keymap.set({ 'n', 'x' }, key, clamp(key), opts)
      end
      -- Quit
      vim.keymap.set('n', 'q', 'ZZ', opts)
      vim.keymap.set('n', '<Esc>', 'ZZ', opts)
    else
      -- Automatically enter insert mode when switching to a terminal buffer
      vim.cmd('startinsert')
    end
  end,
})

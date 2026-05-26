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

local terminal_group = vim.api.nvim_create_augroup('TerminalBehavior', { clear = true })
vim.api.nvim_create_autocmd({ 'TermOpen', 'BufEnter' }, {
  group = terminal_group,
  pattern = 'term://*',
  callback = function(args)
    local bufnr = args.buf
    -- Kitty scrollback behaviour
    if vim.fn.getenv('KITTY_SCROLLBACK') == '1' then
      -- Read-only
      vim.bo[bufnr].bufhidden = 'wipe'
      vim.bo[bufnr].modifiable = false
      vim.bo[bufnr].buflisted = false
      vim.bo[bufnr].swapfile = false
      -- Disable insert/terminal mode
      vim.api.nvim_create_autocmd('TermEnter', {
        group = terminal_group,
        buffer = bufnr,
        callback = function() vim.cmd('stopinsert') end,
      })
      -- Quit
      local opts = { buffer = true, silent = true }
      vim.keymap.set('n', 'q', 'ZZ', opts)
      vim.keymap.set('n', '<Esc>', 'ZZ', opts)
      -- Get last non-empty line
      local last_row = 1
      local last_row_string = tostring(last_row)
      vim.defer_fn(function()
        last_row = vim.fn.prevnonblank(vim.fn.line('$'))
        -- Go to last non-empty line
        vim.api.nvim_win_set_cursor(0, { last_row, 0 })
        last_row_string = tostring(last_row)
      end, 100)
      -- Clamp to last non-empty line
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'WinScrolled' }, {
        group = terminal_group,
        buffer = bufnr,
        callback = function()
          if vim.fn.line('.') > last_row then
            vim.cmd(last_row_string)
          end
        end,
      })
    else
      -- Automatically enter insert mode when switching to a terminal buffer
      vim.cmd('startinsert')
    end
  end,
})

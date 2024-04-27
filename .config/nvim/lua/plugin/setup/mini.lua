-- stylua: ignore
return { -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  event = 'VeryLazy',
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [']quote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup({ n_lines = 500 })

    -- Align text interactively
    --
    -- Examples:
    --  - ga= - g[A]lign with [=]modifier
    --  - gA= - start_with_preview
    require('mini.align').setup()

    -- Go forward/backward with square brackets
    require('mini.bracketed').setup()

    -- Buffer removing (unshow, delete, wipeout), which saves window layout
    require('mini.bufremove').setup()
    vim.keymap.set('n', '<Leader>bd', function()
      local bd = require("mini.bufremove").delete
      if vim.bo.modified then
        local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
        if choice == 1 then -- Yes
          vim.cmd.write()
          bd(0)
        elseif choice == 2 then -- No
          bd(0, true)
        end
      else
        bd(0)
      end
    end, { desc = '[B]uffer [D]elete' })

    -- Automatic highlighting of word under cursor
    require('mini.cursorword').setup()

    -- Highlight patterns in text
    -- Helper functions to get pattern for standalone texts in upper, sentence and lower case
    local function standalone(text) return '%f[%w]()' .. text .. '()%f[%W]' end
    local function getPattern(texts)
      local pattern = {}
      for _, text in ipairs(texts) do
        local lower = string.lower(text)
        table.insert(pattern, standalone(string.upper(text)))
        table.insert(pattern, standalone(lower:sub(1,1):upper() .. lower:sub(2)))
        table.insert(pattern, standalone(lower))
      end
      return pattern
    end

    local hipatterns = require('mini.hipatterns')
    hipatterns.setup({
      highlighters = {
        -- Highlight standalone texts 'FIXME', 'ERROR', 'HACK', 'WARN', 'TODO', 'INFO', 'NOTE', 'DEBUG', 'TEST'
        -- 'ERROR', 'Error', 'error'
        fixme = { pattern = getPattern({ 'FIXME', 'ERROR' }),        group = 'MiniHipatternsFixme' },
        hack  = { pattern = getPattern({ 'HACK', 'WARN' }),          group = 'MiniHipatternsHack' },
        todo  = { pattern = getPattern({ 'TODO', 'INFO' }),          group = 'MiniHipatternsTodo' },
        note  = { pattern = getPattern({ 'NOTE', 'DEBUG', 'TEST' }), group = 'MiniHipatternsNote' },

        -- Highlight hex color strings (`#rrggbb`) using that color
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    })

    -- Visualize and work with indent scope
    require('mini.indentscope').setup({
      symbol = "│",
      options = { try_as_border = true },
      draw = { animation = function() return 0 end }
    })
    -- Toggle indent scope
    vim.keymap.set('n', '<Leader>is', '<cmd>lua vim.g.miniindentscope_disable = not vim.g.miniindentscope_disable<CR>',
      { desc = 'Toggle [I]ndent [S]cope', silent = true })
    -- Toggle all indent lines and scope
    local toggleIndent = function()
      local ibl = require('ibl')
      local conf = require('ibl.config')
      local anyEnabled = (not vim.g.miniindentscope_disable) or conf.get_config(-1).enabled
      if anyEnabled then
        vim.notify('Disabling all indent lines and scope')
        ibl.update({ enabled = false })
        vim.g.miniindentscope_disable = true
      else
        vim.notify('Enabling all indent lines and scope')
        ibl.update({ enabled = true })
        vim.g.miniindentscope_disable = false
      end
    end
    vim.keymap.set('n', '<Leader>ia', toggleIndent,
      { desc = 'Toggle [I]ndent [A]ll', silent = true })

    -- "f, F, t, T, ;" to Jump to next/previous single character
    require('mini.jump').setup()
    -- "Enter" to jump within visible lines via iterative label filtering
    require('mini.jump2d').setup()

    -- Move any selection in any direction
    -- Defaults are Alt (Meta) + hjkl
    require('mini.move').setup()
    -- Map Alt (Meta) + hjkl to arrow keys
    vim.keymap.set({ 'v', 'n' }, '<M-left>',  '<M-h>', { desc = 'Move selection left',  remap = true })
    vim.keymap.set({ 'v', 'n' }, '<M-right>', '<M-l>', { desc = 'Move selection right', remap = true })
    vim.keymap.set({ 'v', 'n' }, '<M-down>',  '<M-j>', { desc = 'Move selection down',  remap = true })
    vim.keymap.set({ 'v', 'n' }, '<M-up>',    '<M-k>', { desc = 'Move selection up',    remap = true })

    -- "gS" to Toggle split and join arguments
    require('mini.splitjoin').setup()

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    -- Supports dot-repeat
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()
  end,
  init = function()
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'help', 'dashboard', 'lazy', 'mason', 'notify', 'toggleterm', 'lazyterm' },
      callback = function()
        vim.b.miniindentscope_disable = true
      end,
    })
  end,
}

-- To re-enable these features, put it inside of config = function() ... end

--[[ -- Minimal and fast autopairs
require('mini.pairs').setup() ]]

--[[ -- Simple and easy statusline.
-- Similar to nvim-lualine/lualine.nvim
--  You could remove this setup call if you don't like it,
--  and try some other statusline plugin
local statusline = require 'mini.statusline'
statusline.setup()

-- You can configure sections in the statusline by overriding their
-- default behavior. For example, here we set the section for
-- cursor location to LINE:COLUMN
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
  return '%2l:%-2v'
end ]]

--[[ Show next key clues
-- Similar to folke/which-key.nvim
local miniclue = require('mini.clue')
miniclue.setup({
  triggers = {
    -- Leader triggers
    { mode = 'n', keys = '<Leader>' },
    { mode = 'x', keys = '<Leader>' },

    -- Built-in completion
    { mode = 'i', keys = '<C-x>' },

    -- `g` key
    { mode = 'n', keys = 'g' },
    { mode = 'x', keys = 'g' },

    -- Marks
    { mode = 'n', keys = "'" },
    { mode = 'n', keys = '`' },
    { mode = 'x', keys = "'" },
    { mode = 'x', keys = '`' },

    -- Registers
    { mode = 'n', keys = '"' },
    { mode = 'x', keys = '"' },
    { mode = 'i', keys = '<C-r>' },
    { mode = 'c', keys = '<C-r>' },

    -- Window commands
    { mode = 'n', keys = '<C-w>' },

    -- `z` key
    { mode = 'n', keys = 'z' },
    { mode = 'x', keys = 'z' },
  },

  clues = {
    -- Enhance this by adding descriptions for <Leader> mapping groups
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
}) ]]
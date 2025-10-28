-- stylua: ignore
return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    event = 'VeryLazy',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      -- NOTE:: use closing `)]` brackets to surround textobjects without spaces
      --        use opening `([` brackets to surround textobjects with spaces
      require('mini.ai').setup({
        n_lines = 500,
        custom_textobjects = {
          b = { { '%b()', '%b[]', '%b{}', '%b<>' }, '^.().*().$' },
        },
      })

      -- Align text interactively
      --
      -- Examples:
      --  - ga= - g[A]lign with [=]modifier
      --  - gA= - start_with_preview
      require('mini.align').setup()

      -- Common configuration presets
      --[[ mappings.basic
    |Keys   |     Modes       |                  Description                  |
    |-------|-----------------|-----------------------------------------------|
    | go    | Normal          | Add [count] empty lines after cursor          |
    | gO    | Normal          | Add [count] empty lines before cursor         |
    | gy    | Normal, Visual  | Copy to system clipboard                      |
    | gp    | Normal, Visual  | Paste from system clipboard                   |
    | gV    | Normal          | Visually select latest changed or yanked text |
    | g/    | Visual          | Search inside current visual selection        |
    | *     | Visual          | Search forward for current visual selection   |
    | #     | Visual          | Search backward for current visual selection  | ]]
      require('mini.basics').setup({
        -- Options. Set to `false` to disable.
        options = {
          -- Basic options ('number', 'ignorecase', and many more)
          basic = true,
          -- Extra UI features ('winblend', 'cmdheight=0', ...)
          extra_ui = false,
          -- Presets for window borders ('single', 'double', ...)
          win_borders = 'default',
        },
        -- Mappings. Set to `false` to disable.
        mappings = {
          -- Basic mappings (better 'jk', save with Ctrl+S, ...)
          basic = true,
          -- Prefix for mappings that toggle common options ('wrap', 'spell', ...).
          -- Supply empty string to not create these mappings.
          option_toggle_prefix = vim.g.option_toggle_prefix,
          -- Window navigation with <C-hjkl>, resize with <C-arrow>
          -- NOTE: vim-visual-multi uses `Ctrl-<Down/Up>`
          windows = true,
          -- Move cursor in Insert, Command, and Terminal mode with <M-hjkl>
          move_with_alt = true,
        },
        -- Autocommands. Set to `false` to disable
        autocommands = {
          -- Basic autocommands (highlight on yank, start Insert in terminal, ...)
          basic = true,
          -- Set 'relativenumber' only in linewise and blockwise Visual mode
          relnum_in_visual_mode = false,
        },
        -- Whether to disable showing non-error feedback
        silent = false,
      })
      -- Paste from system clipboard and convert ff to unix
      vim.keymap.set('n', 'gp', '"+p<cmd>w | e ++ff=dos | set ff=unix | w<CR>', { desc = 'Paste from system clipboard and convert ff to unix' })
      -- - Paste in Visual with `P` to not copy selected text (`:h v_P`)
      vim.keymap.set('x', 'gp', '"+P<cmd>w | e ++ff=dos | set ff=unix | w<CR>', { desc = 'Paste from system clipboard and convert ff to unix' })

      -- Go forward/backward with square brackets
      require('mini.bracketed').setup()
      vim.keymap.set('n', 'u', 'uzz<Cmd>lua MiniBracketed.register_undo_state()<CR>')
      vim.keymap.set('n', '<C-r>', '<C-r>zz<Cmd>lua MiniBracketed.register_undo_state()<CR>')

      -- Automatic highlighting of word under cursor
      require('mini.cursorword').setup()

      -- Highlight patterns in text
      local hipatterns = require('mini.hipatterns')
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
      local colors = require('colors')
      hipatterns.setup({
        highlighters = {
          -- Highlight standalone texts
          FIX  = { pattern = getPattern({ 'FIX', 'ERROR', 'FIXME', 'BUG', 'FIXIT', 'ISSUE', 'FAILED' }), group = hipatterns.compute_hex_color_group(colors.red, 'bg') },
          WARN = { pattern = getPattern({ 'WARN', 'WARNING' }),                                          group = hipatterns.compute_hex_color_group(colors.orange, 'bg') },
          HACK = { pattern = getPattern({ 'HACK' }),                                                     group = hipatterns.compute_hex_color_group(colors.yellow, 'bg') },
          PERF = { pattern = getPattern({ 'PERF', 'OPTIM', 'PERFORMANCE', 'OPTIMIZE', 'PASSED' }),       group = hipatterns.compute_hex_color_group(colors.green, 'bg') },
          TODO = { pattern = getPattern({ 'TODO' }),                                                     group = hipatterns.compute_hex_color_group(colors.blue, 'bg') },
          NOTE = { pattern = getPattern({ 'NOTE', 'INFO', 'HINT' }),                                     group = hipatterns.compute_hex_color_group(colors.cyan, 'bg') },
          TEST = { pattern = getPattern({ 'TEST', 'DEBUG', 'TESTING' }),                                 group = hipatterns.compute_hex_color_group(colors.purple, 'bg') },
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
      vim.keymap.set({ 'n', 'v' }, vim.g.option_toggle_prefix .. 'S', '<cmd>lua vim.g.miniindentscope_disable = not vim.g.miniindentscope_disable<CR>',
        { desc = "Toggle 'miniindentscope'", silent = true })
      -- Toggle all indent lines and scope
      function ToggleIndent()
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
      vim.keymap.set({ 'n', 'v' }, vim.g.option_toggle_prefix .. 'a', ToggleIndent,
        { desc = 'Toggle all indents', silent = true })

      -- Move any selection in any direction
      -- Defaults are Alt (Meta) + hjkl
      require('mini.move').setup()
      -- Map Alt (Meta) + hjkl to arrow keys
      vim.keymap.set({ 'v', 'n' }, '<M-left>',  '<M-h>', { desc = 'Move selection left',  remap = true })
      vim.keymap.set({ 'v', 'n' }, '<M-right>', '<M-l>', { desc = 'Move selection right', remap = true })
      vim.keymap.set({ 'v', 'n' }, '<M-down>',  '<M-j>', { desc = 'Move selection down',  remap = true })
      vim.keymap.set({ 'v', 'n' }, '<M-up>',    '<M-k>', { desc = 'Move selection up',    remap = true })

      -- Text edit operators
      -- - g= - Evaluate text and replace with output
      -- - gx - Exchange text regions
      -- - gm - Multiply (duplicate) text
      -- - gr - Replace text with register
      -- - gs - Sort text
      require('mini.operators').setup()

      -- Minimal and fast autopairs
      require('mini.pairs').setup()

      -- "gS" to Toggle split and join arguments
      require('mini.splitjoin').setup()

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      -- Supports dot-repeat
      --
      -- Examples:
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()
      -- NOTE: Disable the feature in fc6fbc3
      vim.keymap.del({ 'n', 'x' }, 's')

      -- Hightlight trailing whitespace
      require('mini.trailspace').setup()
    end,
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'help', 'dashboard', 'lazy', 'mason', 'notify', 'toggleterm', 'lazyterm' },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },
  { -- Non lazy load modules
    'echasnovski/mini.files',
    config = function()
      -- Navigate and manipulate file system
      require('plugins.custom.MiniFiles')
    end
  },
}

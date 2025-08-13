return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files', { hidden = true })" },
          { icon = " ", key = "e", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('grep', { hidden = true })" },
          { icon = " ", key = ".", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "n", desc = "Config", action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config'), follow = true })" },
          -- { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒲 ", key = "z", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = 'header' },
        { icon = ' ', title = 'Keymaps', section = 'keys', indent = 2, padding = 1 },
        { icon = ' ', title = 'Recent Files Cwd', section = 'recent_files', indent = 2, padding = 1, limit = 3, cwd = true },
        { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1, limit = 3 },
        { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
        { section = 'startup' },
      },
    },
    input = { enabled = true },
    quickfile = { enabled = true },
    lazygit = {
      win = { style = 'dashboard' },
    },
    picker = {
      prompt = ' ',
      sources = {
        grep = {
          title = 'Grep -i',
          actions = {
            -- Disable globally 'Fields cannot be injected into the reference of'
            ---@diagnostic disable: inject-field
            toggle_case = function(picker)
              -- Initialize args
              picker.opts.args = picker.opts.args or {}
              -- Create lookup table
              local args_lookup = {}
              for i, arg in ipairs(picker.opts.args) do
                args_lookup[arg] = i
              end
              -- Toggle '-s' based on lookup
              if args_lookup['-s'] then
                table.remove(picker.opts.args, args_lookup['-s'])
                picker.title = 'Grep -i'
              else
                table.insert(picker.opts.args, '-s')
                picker.title = 'Grep -s'
              end
              picker:find { refresh = true }
            end,
          },
          win = {
            input = {
              keys = {
                ['<A-s>'] = { 'toggle_case', mode = { 'i', 'n' } },
              },
            },
          },
        },
        explorer = {
          focus = 'input',
          actions = {
            go_in_if_dir = function(picker, item)
              if item.dir then
                picker:action 'confirm'
              end
            end,
          },
          win = {
            input = {
              keys = {
                ['<CR>'] = { { 'confirm', 'close' } }, ---@diagnostic disable-line: assign-type-mismatch
              },
            },
            -- NOTE: This only works for focus = 'list'
            list = {
              keys = {
                ['l'] = 'go_in_if_dir', -- Same as ./custom/MiniFiles.lua
                ['L'] = { { 'confirm', 'close' } }, ---@diagnostic disable-line: assign-type-mismatch
                ['<CR>'] = { { 'confirm', 'close' } }, ---@diagnostic disable-line: assign-type-mismatch
              },
            },
          },
        },
      },
      focus = 'input',
      layout = {
        cycle = false,
        --- Use the default layout or vertical if the window is too narrow
        -- preset = function() return vim.o.columns >= 120 and 'default' or 'vertical' end,
        preset = 'vertical',
      },
      layouts = {
        -- Override the vertical layout
        vertical = {
          layout = {
            backdrop = false,
            width = 0.8,
            min_width = 80,
            height = 0.8,
            min_height = 30,
            box = 'vertical',
            border = 'rounded',
            title = '{title} {live} {flags}',
            title_pos = 'center',
            { win = 'input', height = 1, border = 'bottom' },
            { win = 'list', border = 'none' },
            { win = 'preview', title = '{preview}', height = 0.65, border = 'top' },
          },
        }
      },
      -- `matcher` is only used in non-live mode
      ---@class snacks.picker.matcher.Config
      matcher = {
        fuzzy = true, -- use fuzzy matching
        smartcase = true, -- use smartcase
        ignorecase = true, -- use ignorecase
        sort_empty = false, -- sort results when the search string is empty
        filename_bonus = true, -- give bonus for matching file names (last part of the path)
        file_pos = false, -- support patterns like `file:line:col` and `file:line`
        -- the bonusses below, possibly require string concatenation and path normalization,
        -- so this can have a performance impact for large lists and increase memory usage
        cwd_bonus = true, -- give bonus for matching files in the cwd
        frecency = true, -- frecency bonus
        history_bonus = true, -- give more weight to chronological order
      },
      sort = {
        -- default sort is by score, text length and index
        fields = { 'score:desc', '#text', 'idx' },
      },
      ui_select = true, -- replace `vim.ui.select` with the snacks picker
      ---@class snacks.picker.formatters.Config
      formatters = {
        text = {
          ft = nil, ---@type string? filetype for highlighting
        },
        file = {
          filename_first = false, -- display filename before the file path
          truncate = 40, -- truncate the file path to (roughly) this length
          filename_only = false, -- only show the filename
        },
        selected = {
          show_always = false, -- only show the selected column when there are multiple selections
          unselected = true, -- use the unselected icon for unselected items
        },
        severity = {
          icons = true, -- show severity icons
          level = false, -- show severity level
        },
      },
      ---@class snacks.picker.previewers.Config
      previewers = {
        git = {
          native = false, -- use native (terminal) or Neovim for previewing git diffs and commits
        },
        file = {
          max_size = 1024 * 1024, -- 1MB
          max_line_length = 500, -- max line length
          ft = nil, ---@type string? filetype for highlighting. Use `nil` for auto detect
        },
        man_pager = nil, ---@type string? MANPAGER env to use for `man` preview
      },
      ---@class snacks.picker.jump.Config
      jump = {
        jumplist = true, -- save the current position in the jumplist
        tagstack = false, -- save the current position in the tagstack
        reuse_win = false, -- reuse an existing window if the buffer is already open
        close = true, -- close the picker when jumping/editing to a location (defaults to true)
        match = false, -- jump to the first match position. (useful for `lines`)
      },
      toggles = {
        follow = 'f',
        hidden = 'h',
        ignored = 'i',
        modified = 'm',
        regex = { icon = 'R', value = false },
      },
      win = {
        -- input window
        input = {
          keys = {
            -- to close the picker on ESC instead of going to normal mode,
            -- add the following keymap to your config
            ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
            -- ['<Esc>'] = 'close',
            ['/'] = 'toggle_focus',
            ['<C-Down>'] = { 'history_forward', mode = { 'i', 'n' } },
            ['<C-Up>'] = { 'history_back', mode = { 'i', 'n' } },
            ['<C-c>'] = { 'close', mode = 'i' },
            ['<C-w>'] = { '<C-s-w>', mode = { 'i' }, expr = true, desc = 'delete word' },
            ['<CR>'] = { 'confirm', mode = { 'n', 'i' } },
            ['<Down>'] = { 'list_down', mode = { 'i', 'n' } },
            ['<S-CR>'] = { { 'pick_win', 'jump' }, mode = { 'n', 'i' } },
            ['<S-Tab>'] = { 'select_and_prev', mode = { 'i', 'n' } },
            ['<Tab>'] = { 'select_and_next', mode = { 'i', 'n' } },
            ['<Up>'] = { 'list_up', mode = { 'i', 'n' } },
            ['<A-d>'] = { 'inspect', mode = { 'n', 'i' } },
            ['<A-f>'] = { 'toggle_follow', mode = { 'i', 'n' } },
            ['<A-h>'] = { 'toggle_hidden', mode = { 'i', 'n' } },
            ['<A-i>'] = { 'toggle_ignored', mode = { 'i', 'n' } },
            ['<A-m>'] = { 'toggle_maximize', mode = { 'i', 'n' } },
            ['<A-p>'] = { 'toggle_preview', mode = { 'i', 'n' } },
            ['<A-w>'] = { 'cycle_win', mode = { 'i', 'n' } },
            ['<C-a>'] = { 'select_all', mode = { 'n', 'i' } },
            ['<C-b>'] = { 'preview_scroll_up', mode = { 'i', 'n' } },
            ['<C-d>'] = { 'list_scroll_down', mode = { 'i', 'n' } },
            ['<PageDown>'] = { 'list_scroll_down', mode = { 'i', 'n' } },
            ['<C-f>'] = { 'preview_scroll_down', mode = { 'i', 'n' } },
            ['<C-g>'] = { 'toggle_live', mode = { 'i', 'n' } },
            ['<C-j>'] = { 'list_down', mode = { 'i', 'n' } },
            ['<C-k>'] = { 'list_up', mode = { 'i', 'n' } },
            ['<C-n>'] = { 'history_forward', mode = { 'i', 'n' } },
            ['<C-p>'] = { 'history_back', mode = { 'i', 'n' } },
            ['<C-q>'] = { 'qflist', mode = { 'i', 'n' } },
            ['<C-s>'] = { 'edit_split', mode = { 'i', 'n' } },
            ['<C-u>'] = { 'list_scroll_up', mode = { 'i', 'n' } },
            ['<PageUp>'] = { 'list_scroll_up', mode = { 'i', 'n' } },
            ['<C-v>'] = { 'edit_vsplit', mode = { 'i', 'n' } },
            ['?'] = 'toggle_help_input',
            ['G'] = 'list_bottom',
            ['gg'] = 'list_top',
            ['j'] = 'list_down',
            ['k'] = 'list_up',
            ['q'] = 'close',
            ['J'] = { 'preview_scroll_down', mode = { 'i', 'n' } },
            ['K'] = { 'preview_scroll_up', mode = { 'i', 'n' } },
            ['H'] = { 'preview_scroll_left', mode = { 'i', 'n' } },
            ['L'] = { 'preview_scroll_right', mode = { 'i', 'n' } },
          },
          b = {
            minipairs_disable = true,
          },
        },
        -- result list window
        list = {
          keys = {
            ['/'] = 'toggle_focus',
            ['<2-LeftMouse>'] = 'confirm',
            ['<CR>'] = 'confirm',
            ['<Down>'] = 'list_down',
            ['<Esc>'] = 'close',
            ['<S-CR>'] = { { 'pick_win', 'jump' } },
            ['<S-Tab>'] = { 'select_and_prev', mode = { 'n', 'x' } },
            ['<Tab>'] = { 'select_and_next', mode = { 'n', 'x' } },
            ['<Up>'] = 'list_up',
            ['<A-d>'] = 'inspect',
            ['<A-f>'] = 'toggle_follow',
            ['<A-h>'] = 'toggle_hidden',
            ['<A-i>'] = 'toggle_ignored',
            ['<A-m>'] = 'toggle_maximize',
            ['<A-p>'] = 'toggle_preview',
            ['<A-w>'] = 'cycle_win',
            ['<C-a>'] = 'select_all',
            ['<C-b>'] = 'preview_scroll_up',
            ['<C-d>'] = 'list_scroll_down',
            ['<C-f>'] = 'preview_scroll_down',
            ['<C-j>'] = 'list_down',
            ['<C-k>'] = 'list_up',
            ['<C-n>'] = 'list_down',
            ['<C-p>'] = 'list_up',
            ['<C-s>'] = 'edit_split',
            ['<C-u>'] = 'list_scroll_up',
            ['<C-v>'] = 'edit_vsplit',
            ['?'] = 'toggle_help_list',
            ['G'] = 'list_bottom',
            ['gg'] = 'list_top',
            ['i'] = 'focus_input',
            ['j'] = 'list_down',
            ['k'] = 'list_up',
            ['q'] = 'close',
            ['zb'] = 'list_scroll_bottom',
            ['zt'] = 'list_scroll_top',
            ['zz'] = 'list_scroll_center',
          },
          wo = {
            conceallevel = 2,
            concealcursor = 'nvc',
          },
        },
        -- preview window
        preview = {
          keys = {
            ['<Esc>'] = 'close',
            ['q'] = 'close',
            ['i'] = 'focus_input',
            ['<ScrollWheelDown>'] = 'list_scroll_wheel_down',
            ['<ScrollWheelUp>'] = 'list_scroll_wheel_up',
            ['<A-w>'] = 'cycle_win',
          },
        },
      },
      ---@class snacks.picker.icons
      icons = {
        files = {
          enabled = true, -- show file icons
        },
        keymaps = {
          nowait = '󰓅 '
        },
        tree = {
          vertical = '│ ',
          middle   = '├╴',
          last     = '└╴',
        },
        undo = {
          saved   = ' ',
        },
        ui = {
          live        = '󰐰 ',
          hidden      = 'h',
          ignored     = 'i',
          follow      = 'f',
          selected    = '● ',
          unselected  = '○ ',
          -- selected = ' ',
        },
        git = {
          enabled   = true, -- show git icons
          commit    = '󰜘 ', -- used by git log
          staged    = '●', -- staged changes. always overrides the type icons
          added     = '',
          deleted   = '',
          ignored   = ' ',
          modified  = '○',
          renamed   = '',
          unmerged  = ' ',
          untracked = '?',
        },
        diagnostics = {
          Error = ' ',
          Warn  = ' ',
          Hint  = ' ',
          Info  = ' ',
        },
        kinds = {
          Array         = ' ',
          Boolean       = '󰨙 ',
          Class         = ' ',
          Color         = ' ',
          Control       = ' ',
          Collapsed     = ' ',
          Constant      = '󰏿 ',
          Constructor   = ' ',
          Copilot       = ' ',
          Enum          = ' ',
          EnumMember    = ' ',
          Event         = ' ',
          Field         = ' ',
          File          = ' ',
          Folder        = ' ',
          Function      = '󰊕 ',
          Interface     = ' ',
          Key           = ' ',
          Keyword       = ' ',
          Method        = '󰊕 ',
          Module        = ' ',
          Namespace     = '󰦮 ',
          Null          = ' ',
          Number        = '󰎠 ',
          Object        = ' ',
          Operator      = ' ',
          Package       = ' ',
          Property      = ' ',
          Reference     = ' ',
          Snippet       = '󱄽 ',
          String        = ' ',
          Struct        = '󰆼 ',
          Text          = ' ',
          TypeParameter = ' ',
          Unit          = ' ',
          Unknown        = ' ',
          Value         = ' ',
          Variable      = '󰀫 ',
        },
      },
      ---@class snacks.picker.debug
      debug = {
        scores = false, -- show scores in the list
        leaks = false, -- show when pickers don't get garbage collected
      },
    },
  },
  keys = {
    { '<Leader>Z',  function() Snacks.zen.zoom() end, desc = 'Toggle Zoom' },
    { '<Leader>,',  function() Snacks.scratch() end, desc = 'Toggle Scratch Buffer' },
    { '<Leader>S',  function() Snacks.scratch.select() end, desc = 'Select Scratch Buffer' },
    { '<Leader>bd', function() Snacks.bufdelete() end, desc = 'Delete Buffer' },
    { '<Leader>rf', function() Snacks.rename.rename_file() end, desc = '[R]ename [F]ile' },
    { '<Leader>gB', function() Snacks.git.blame_line() end, desc = 'Git Blame Line' },
    { '<Leader>lg', function() Snacks.lazygit() end, desc = 'Lazygit' },
    { vim.g.option_toggle_prefix .. 'gl', function() Snacks.lazygit.log() end, desc = 'Lazygit Log (cwd)' },
    { vim.g.option_toggle_prefix .. 'gf', function() Snacks.lazygit.log_file() end, desc = 'Lazygit Current File History' },

    --[[ picker keymaps ]]
    { '<Leader><Leader>', function() Snacks.picker.buffers() end, desc = '[ ] Find existing buffers' },
    { '<Leader>e', function() Snacks.explorer({ hidden = true }) end, desc = 'File [E]xplorer' },
    { '<Leader>E', function() Snacks.explorer() end, desc = 'File [E]xplorer' },
    --[[ git ]]
    { '<Leader>gb', function() Snacks.picker.git_branches() end, desc = 'Git Branches' },
    { '<Leader>gd', function() Snacks.picker.git_diff() end, desc = 'Git Diff (Hunks)' },
    { '<Leader>gf', function() Snacks.picker.git_files() end, desc = '[S]earch Git [F]iles' },
    { '<Leader>gF', function() Snacks.picker.git_log_file() end, desc = 'Git Log File' },
    { '<Leader>gl', function() Snacks.picker.git_log() end, desc = 'Git Log' },
    { '<Leader>gL', function() Snacks.picker.git_log_line() end, desc = 'Git Log Line' },
    { '<Leader>gs', function() Snacks.picker.git_status() end, desc = 'Git Status' },
    --[[ search ]]
    { '<Leader>s"', function() Snacks.picker.registers() end, desc = '[S]earch ["] Registers' },
    { '<Leader>s.', function() Snacks.picker.recent() end, desc = '[S]earch Recent Files ("." for repeat)' },
    { '<Leader>s/', function() Snacks.picker.search_history() end, desc = 'Search History' },
    { '<Leader>sa', function() Snacks.picker.autocmds() end, desc = 'Autocmds' },
    { '<Leader>sB', function() Snacks.picker.grep_buffers() end, desc = 'Grep Open Buffers' },
    { '<Leader>sb', function() Snacks.picker.lines() end, desc = 'Buffer Lines' },
    { '<Leader>sc', function() Snacks.picker.command_history() end, desc = '[S]earch [C]ommand history' },
    { '<Leader>sC', function() Snacks.picker.commands() end, desc = 'Commands' },
    { '<Leader>sD', function() Snacks.picker.diagnostics() end, desc = '[S]earch [D]iagnostics' },
    { '<Leader>sd', function() Snacks.picker.diagnostics_buffer() end, desc = '[S]earch [D]iagnostics buffer' },
    { '<Leader>sf', function() Snacks.picker.files({ hidden = true }) end, desc = '[S]earch [F]iles' },
    { '<Leader>sF', function() Snacks.picker.smart() end, desc = '[S]mart Find [F]iles' },
    { '<Leader>sg', function() Snacks.picker.grep({ hidden = true }) end, desc = 'Grep' }, -- By default, rg is case insensitive
    { '<Leader>sG', function() Snacks.picker.grep({ hidden = true, args = { '-s' } }) end, desc = 'Grep --case-sensitive' },
    { '<Leader>sh', function() Snacks.picker.help() end, desc = '[S]earch [H]elp' },
    { '<Leader>sH', function() Snacks.picker.highlights() end, desc = 'Highlights' },
    { '<Leader>si', function() Snacks.picker.icons() end, desc = 'Icons' },
    { '<Leader>sj', function() Snacks.picker.jumps() end, desc = 'Jumps' },
    { '<Leader>sk', function() Snacks.picker.keymaps() end, desc = '[S]earch [K]eymaps' },
    { '<Leader>sl', function() Snacks.picker.loclist() end, desc = 'Location List' },
    { '<Leader>sM', function() Snacks.picker.man() end, desc = 'Man Pages' },
    { '<Leader>sm', function() Snacks.picker.marks() end, desc = 'Marks' },
    { '<Leader>sn', function() Snacks.picker.files({ cwd = vim.fn.stdpath('config'), follow = true }) end, desc = '[S]earch [N]eovim files' },
    { '<Leader>sp', function() Snacks.picker.projects() end, desc = '[S]earch [P]rojects' },
    { '<Leader>sq', function() Snacks.picker.qflist() end, desc = '[S]earch [Q]uickfix' },
    { '<Leader>sr', function() Snacks.picker.resume() end, desc = '[S]earch [R]esume last command/query' },
    { '<Leader>su', function() Snacks.picker.undo() end, desc = 'Undo History' },
    { '<Leader>sw', function() Snacks.picker.grep_word() end, desc = 'Visual selection or word', mode = { 'n', 'x' } },
    { '<Leader>sz', function() Snacks.picker.lazy() end, desc = 'Search for lazy plugin spec' },
    -- { '<Leader>uC', function() Snacks.picker.colorschemes() end, desc = 'Colorschemes' },
    --[[ gl[o]b search ]]
    { '<Leader>ogc', function() Snacks.picker.grep({ hidden = true, glob = '*.csv' }) end, desc = 'Grep *.csv' },
    { '<Leader>ogq', function() Snacks.picker.grep({ hidden = true, glob = '*.q' }) end, desc = 'Grep *.q' },
    { '<Leader>ogs', function() Snacks.picker.grep({ hidden = true, glob = '*.sh' }) end, desc = 'Grep *.sh' },
    { '<Leader>ofc', function() Snacks.picker.files({ hidden = true, glob = '*.csv' }) end, desc = '[S]earch [F]iles *.csv' },
    { '<Leader>ofq', function() Snacks.picker.files({ hidden = true, glob = '*.q' }) end, desc = '[S]earch [F]iles *.q' },
    { '<Leader>ofs', function() Snacks.picker.files({ hidden = true, glob = '*.sh' })  end, desc = '[S]earch [F]iles *.sh' },
    --[[ LSP ]]
    -- Jump to the definition of the word under your cursor.
    --  This is where a variable was first declared, or where a function is defined, etc.
    --  To jump back, press <C-t>.
    { 'gd', function() Snacks.picker.lsp_definitions() end, desc = '[G]oto [D]efinition' },
    -- WARN: This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header
    { 'gD', function() Snacks.picker.lsp_declarations() end, desc = 'Goto Declaration' },
    -- Find references for the word under your cursor.
    -- `gr` is used by mini-operators
    { 'gR', function() Snacks.picker.lsp_references() end, nowait = true, desc = '[G]oto [R]eferences' },
    -- Jump to the implementation of the word under your cursor.
    --  Useful when your language has ways of declaring types without an actual implementation.
    { 'gI', function() Snacks.picker.lsp_implementations() end, desc = '[G]oto [I]mplementation' },
    -- Jump to the type of the word under your cursor.
    --  Useful when you're not sure what type a variable is and you want to see
    --  the definition of its *type*, not where it was *defined*.
    { 'gY', function() Snacks.picker.lsp_type_definitions() end, desc = 'Goto T[y]pe Definition' },
    --  Symbols are things like variables, functions, types, etc.
    { '<Leader>ss', function() Snacks.picker.lsp_symbols() end, desc = 'LSP Symbols' },
    { '<Leader>sS', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'LSP Workspace Symbols' },
  },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesActionRename',
      callback = function(event)
        Snacks.rename.on_rename_file(event.data.from, event.data.to)
      end,
    })
  end,
}

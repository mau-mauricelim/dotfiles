-- NOTE: Plugins can specify dependencies.
--
-- The dependencies are proper plugin specifications as well - anything
-- you do for a plugin at the top level, you can do for a dependency.
--
-- Use the `dependencies` key to specify the dependencies of a particular plugin
--
return { -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  -- Use the VeryLazy event for things that can
  -- load later and are not important for the initial UI
  event = 'VeryLazy',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for install instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable('make') == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    -- Useful for getting pretty icons, but requires special font.
    --  If you already have a Nerd Font, or terminal set up with fallback fonts
    --  you can enable this
    { 'nvim-tree/nvim-web-devicons' },
    -- Clipboard manager
    { 'AckslD/nvim-neoclip.lua' },
  },
  -- stylua: ignore
  config = function()
    -- Telescope is a fuzzy finder that comes with a lot of different things that
    -- it can fuzzy find! It's more than just a "file finder", it can search
    -- many different aspects of Neovim, your workspace, LSP, and more!
    --
    -- The easiest way to use telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- After running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of help_tags options and
    -- a corresponding preview of the help.
    --
    -- Two important keymaps to use while in telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`

    -- File and text search in hidden files and directories
    local telescope = require('telescope')
    local telescopeConfig = require('telescope.config')

    -- Clone the default Telescope configuration
    local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

    -- Telescope actions
    local actions = require('telescope.actions')
    local action_layout = require('telescope.actions.layout')

    -- I want to search in hidden/dot files.
    table.insert(vimgrep_arguments, '--hidden')
    -- I don't want to search in the `.git` directory.
    table.insert(vimgrep_arguments, '--glob')
    table.insert(vimgrep_arguments, '!**/.git/*')

    -- Line number preview
    vim.cmd('autocmd User TelescopePreviewerLoaded setlocal number')

    telescope.setup({
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      --
      defaults = {
        -- `hidden = true` is not supported in text grep commands.
        vimgrep_arguments = vimgrep_arguments,

        layout_strategy = 'vertical',
        layout_config = {
          -- Defaults for all strategies as top level options
          width = 0.95,
          height = 0.85,
          -- preview_cutoff = 120,
          prompt_position = 'top',

          -- Overriding for specific options
          horizontal = {
            preview_width = function(_, cols, _)
              if cols > 200 then
                return math.floor(cols * 0.4)
              else
                return math.floor(cols * 0.6)
              end
            end,
          },
          vertical = {
            width = 0.8,
            height = 0.8,
            preview_height = 0.65,
            mirror = true,
          },
          flex = {
            horizontal = {
              preview_width = 0.9,
            },
          },
        },

        mappings = {
            i = {
              ['<C-Enter>'] = actions.to_fuzzy_refine,
              ['<RightMouse>'] = actions.close,
              -- Do not close picker on losing focus
              ['<LeftMouse>'] = actions.nop,
              ['<ScrollWheelDown>'] = actions.preview_scrolling_down,
              ['<ScrollWheelUp>'] = actions.preview_scrolling_up,

              -- Disable open file in horizontal split
              -- Use <C-v> to open file in vsplit
              ['<C-x>'] = false,

              -- Cycle history
              ['<C-j>'] = actions.cycle_history_next,
              ['<C-k>'] = actions.cycle_history_prev,

              -- <Tab/S-Tab> Toggle selection and move to next/prev selection
              -- <C-q> Send all items not filtered to quickfixlist (qflist)
              -- <M-q> Send all selected items to qflist

              ['<M-p>'] = action_layout.toggle_preview,
              ['<M-m>'] = action_layout.toggle_mirror,
            },
        },
      },
      pickers = {
        find_files = {
          find_command =
            ( vim.fn.executable('fd') == 1 and
              { 'fd', '--type', 'f', '--strip-cwd-prefix', '--hidden', '--follow', '--exclude', '.git' }
            ) or
            -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
            ( vim.fn.executable('rg') == 1 and
              { 'rg', '--files', '--hidden', '--glob', '!**/.git/*' }
            ) or
            nil,
        },
        buffers = {
          sort_lastused = true,
          sort_mru = true,
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
          
        },
      },
    })

    -- Enable telescope extensions, if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')
    pcall(require('telescope').load_extension, 'live_grep_args')

    -- See `:help telescope.builtin`
    -- live_grep allows for regex patterns
    local builtin = require('telescope.builtin')
    builtin.current_buffer_live_grep = '<cmd>lua require("telescope.builtin").live_grep({ search_dirs = { vim.fn.expand("%:p") } })<CR>'
    builtin.quickfix_custom = function() builtin.quickfix(); vim.cmd(':cclose') end
    -- Function to search for files with path
    function Files(path) builtin.find_files({ cwd = path }) end
    vim.keymap.set('n', '<leader>sh',       builtin.help_tags,                 { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk',       builtin.keymaps,                   { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf',       builtin.find_files,                { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss',       builtin.builtin,                   { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw',       builtin.grep_string,               { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg',       builtin.live_grep,                 { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd',       builtin.diagnostics,               { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr',       builtin.resume,                    { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>sq',       builtin.quickfix_custom,           { desc = '[S]earch [Q]uickfix' })
    vim.keymap.set('n', '<leader>s.',       builtin.oldfiles,                  { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers,                   { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>/f',       builtin.current_buffer_fuzzy_find, { desc = '[/] [F]uzzy search current buffer' })
    vim.keymap.set('n', '<leader>/g',       builtin.current_buffer_live_grep,  { desc = '[/] [G]rep search current buffer' })
    vim.keymap.set('n', '<leader>sp',      ':lua Files("")<Left><Left>',       { desc = '[S]earch Files in [P]ath' })
    vim.keymap.set('n', '<leader>sc',      '<cmd>Telescope neoclip<CR>',       { desc = '[S]earch [C]lipboard yanked history' })

    -- Also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>so', function()
      builtin.live_grep({
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      })
    end, { desc = '[S]earch in [O]pen Files' })

    -- Shortcut for searching your neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files({ cwd = vim.fn.stdpath 'config' })
    end, { desc = '[S]earch [N]eovim files' })
  end,
}

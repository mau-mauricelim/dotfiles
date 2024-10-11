return {
  'ibhagwan/fzf-lua',
  -- optional for icon support
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  -- stylua: ignore
  config = function()
    local fzf_lua = require('fzf-lua')
    local actions = require('fzf-lua.actions')
    fzf_lua.setup({
      defaults = {
        file_icons = false,
        actions = {
          ['ctrl-t'] = require('trouble.sources.fzf').actions.open,
        },
      },
      winopts = {
        height  = 0.8,
        width   = 0.8,
        preview = {
          -- https://github.com/ibhagwan/fzf-lua/wiki#how-do-i-get-maximum-performance-out-of-fzf-lua
          default     = 'bat_native',
          vertical    = 'down:65%', -- up|down:size
          layout      = 'vertical',
          scrollbar   = 'true',
          scrollchars = { '┃', '' },
        },
      },
      -- https://github.com/ibhagwan/fzf-lua/wiki#how-do-i-setup-input-history-keybinds
      -- Fzf supports saving input history into a history file using `--history` flag.
      -- You can configure a history file globally or per provider.
      -- Once the `--history` flag is supplied fzf will automatically map `ctrl-{n|p}` to `{next|previous}-history`, you can change the default binds under `keymap.fzf`.
      -- Example #1: saving global input history under `~/.local/share/nvim/fzf-lua-history`:
      fzf_opts = {
        ['--history'] = vim.fn.stdpath('data') .. '/fzf-lua-history',
      },
      files = {
        actions = {
          ['ctrl-h'] = actions.toggle_hidden,
        },
      },
      grep = {
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git' --max-columns=4096 -e",
        actions = {
          ['ctrl-h'] = actions.toggle_hidden,
        },
      },
      keymap = {
        builtin = {
          true, -- inherit from defaults
          ['<C-d>'] = 'preview-page-down',
          ['<C-u>'] = 'preview-page-up',
        },
        fzf = {
          true, -- inherit from defaults
          -- Only valid with fzf previewers (bat/cat/git/etc)
          ['ctrl-d'] = 'preview-page-down',
          -- NOTE: Overrides should follow the default mapping key spelling e.g. `ctrl` instead or `Ctrl` here
          ['ctrl-u'] = 'preview-page-up', -- overrides 'unix-line-discard'
          -- To replicate Telescope's ctrl-q behavior:
          -- <C-q> Send all items not filtered to quickfixlist (qflist)
          ['ctrl-q'] = 'select-all+accept',
        },
      },
      actions = {
        files = {
          true, -- inherit from defaults
          -- Pickers inheriting these actions:
          --   files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist,
          --   tags, btags, args, buffers, tabs, lines, blines
          --
          -- Use <C-v> to open file in vsplit, depends on terminal setup
          ['ctrl-x'] = actions.file_vsplit,
        },
        buffers = {
          true, -- inherit from defaults
          -- Use <C-v> to open file in vsplit, depends on terminal setup
          ['ctrl-x'] = actions.buf_vsplit,
        },
      },
    })

    -- Function to search for files with path
    function Files(path) fzf_lua.files({ cwd = path }) end
    local function cfd() vim.fn.expand('%:p:h') end
    fzf_lua.files_cfd = function() fzf_lua.files({ cwd = cfd() }) end
    vim.keymap.set('n', '<Leader>sh',       fzf_lua.helptags,             { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<Leader>sk',       fzf_lua.keymaps,              { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<Leader>sf',       fzf_lua.files,                { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<Leader>sF',       fzf_lua.files_cfd,            { desc = '[S]earch [F]iles (cfd)' })
    vim.keymap.set('n', '<Leader>ss',       fzf_lua.builtin,              { desc = '[S]earch [S]elect fzf-lua builtin commands' })
    vim.keymap.set('n', '<Leader>sw',       fzf_lua.grep_cword,           { desc = '[S]earch current [W]ord under cursor' })
    vim.keymap.set('v', '<Leader>sv',       fzf_lua.grep_visual,          { desc = '[S]earch [V]isual selection' })
    vim.keymap.set('n', '<Leader>sg',       fzf_lua.live_grep,            { desc = '[S]earch by live [g]rep' })
    vim.keymap.set('n', '<Leader>sd',       fzf_lua.diagnostics_document, { desc = '[S]earch document [D]iagnostics' })
    vim.keymap.set('n', '<Leader>sr',       fzf_lua.resume,               { desc = '[S]earch [R]esume last command/query' })
    vim.keymap.set('n', '<Leader>sq',       fzf_lua.quickfix,             { desc = '[S]earch [Q]uickfix' })
    vim.keymap.set('n', '<Leader>s.',       fzf_lua.oldfiles,             { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<Leader>s"',       fzf_lua.registers,            { desc = '[S]earch ["] Registers' })
    vim.keymap.set('n', '<Leader>sc',       fzf_lua.command_history,      { desc = '[S]earch [C]ommand history' })
    vim.keymap.set('n', '<Leader><Leader>', fzf_lua.buffers,              { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<Leader>/g',       fzf_lua.lgrep_curbuf,         { desc = '[/] [G]rep search current buffer' })
    vim.keymap.set('n', '<Leader>/h',       fzf_lua.search_history,       { desc = '[/] Search [H]istory' })
    vim.keymap.set('n', '<Leader>sp',       ':lua Files("")<Left><Left>', { desc = '[S]earch Files in [P]ath' })
    -- Shortcut for searching your neovim configuration files
    vim.keymap.set('n', '<Leader>sn', function()
      fzf_lua.files({ cwd = vim.fn.stdpath('config') })
    end, { desc = '[S]earch [N]eovim files' })
  end,
}

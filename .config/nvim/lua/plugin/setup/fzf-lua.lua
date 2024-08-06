return {
  'ibhagwan/fzf-lua',
  event = 'VeryLazy',
  -- optional for icon support
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  -- stylua: ignore
  config = function()
    local fzf_lua = require('fzf-lua')
    local actions = require('fzf-lua.actions')
    fzf_lua.setup({
      winopts = {
        default = 'bat',
        height  = 0.8,
        width   = 0.8,
        preview = {
          vertical    = 'down:65%', -- up|down:size
          layout      = 'vertical',
          scrollbar   = 'true',
          scrollchars = { "┃", "" },
        },
      },
      keymap = {
        builtin = {
          true, -- inherit from defaults
          ['<C-d>'] = 'preview-page-down',
          ['<C-u>'] = 'preview-page-up',
        },
      },
      actions = {
        files = {
          true, -- inherit from defaults
          -- Use <C-v> to open file in vsplit, depends on terminal setup
          ['Ctrl-x'] = actions.file_vsplit,
        },
        buffers = {
          true, -- inherit from defaults
          -- Use <C-v> to open file in vsplit, depends on terminal setup
          ['Ctrl-x'] = actions.buf_vsplit,
        },
      },
      grep = {
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git' --max-columns=4096 -e",
      },
    })

    -- Function to search for files with path
    function Files(path) fzf_lua.files({ cwd = path }) end
    vim.keymap.set('n', '<Leader>sh',       fzf_lua.helptags,             { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<Leader>sk',       fzf_lua.keymaps,              { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<Leader>sf',       fzf_lua.files,                { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<Leader>ss',       fzf_lua.builtin,              { desc = '[S]earch [S]elect fzf-lua builtin commands' })
    vim.keymap.set('n', '<Leader>sw',       fzf_lua.grep_cword,           { desc = '[S]earch current [W]ord under cursor' })
    vim.keymap.set('v', '<Leader>sv',       fzf_lua.grep_visual,          { desc = '[S]earch [V]isual selection' })
    vim.keymap.set('n', '<Leader>sG',       fzf_lua.grep,                 { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<Leader>sg',       fzf_lua.live_grep,            { desc = '[S]earch by live [g]rep' })
    vim.keymap.set('n', '<Leader>sd',       fzf_lua.diagnostics_document, { desc = '[S]earch document [D]iagnostics' })
    vim.keymap.set('n', '<Leader>sr',       fzf_lua.resume,               { desc = '[S]earch [R]esume last command/query' })
    vim.keymap.set('n', '<Leader>sq',       fzf_lua.quickfix,             { desc = '[S]earch [Q]uickfix' })
    vim.keymap.set('n', '<Leader>s.',       fzf_lua.oldfiles,             { desc = '[S]earch Recent Files ("." for repeat)' })
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

return {
  'stevearc/oil.nvim',
  config = function()
    local oil = require('oil')
    local actions = require('oil.actions')
    oil.setup({
      -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
      skip_confirm_for_simple_edits = true,
      -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
      -- (:help prompt_save_on_select_new_entry)
      prompt_save_on_select_new_entry = false,
      view_options = {
        -- Show files and directories that start with "."
        show_hidden = true,
        -- Sort file names in a more intuitive order for humans. Is less performant,
        -- so you may want to set to false if you work with large directories.
        natural_order = false,
        -- Sort file and directory names case insensitive
        case_insensitive = true,
      },
      keymaps = {
        -- Some useful defaults
        ['g?'] = 'actions.show_help',
        ['<C-p>'] = 'actions.preview',
        ['`'] = 'actions.cd',
        -- Overrides
        ['<C-s>'] = oil.save,
        ['~'] = 'actions.open_terminal',
        ['<Leader>sf'] = {
          -- stylua: ignore
          function() Files(require('oil').get_current_dir()) end,
          mode = 'n',
          nowait = true,
          desc = '[S]earch [F]iles in current directory',
        },
        ['<Leader>sg'] = {
          -- stylua: ignore
          function() require('fzf-lua').live_grep({ cwd = require('oil').get_current_dir() }) end,
          mode = 'n',
          nowait = true,
          desc = '[S]earch by live [g]rep in current directory',
        },
      },
    })
    vim.keymap.set('n', '-', oil.open, { desc = 'Open parent directory' })
    vim.keymap.set('n', '_', actions.open_cwd.callback, { desc = 'Open current working directory' })
  end,
}

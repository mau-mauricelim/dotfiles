return {
  'tpope/vim-fugitive',
  config = function()
    -- Opening and closing folds
    -- zc (close), zo (open), and za (toggle) operate on one level of folding, at the cursor
    vim.keymap.set('n', '<Leader>gd', '<cmd>Gvdiffsplit<CR>', { desc = '[G]it [D]iff split' })
    -- Toggle git blame
    local function toggle_gitblame()
      if vim.bo.filetype == 'fugitiveblame' then
        vim.api.nvim_win_close(0, false)
      else
        vim.cmd('G blame')
      end
    end
    vim.keymap.set('n', '<Leader>gb', function()
      toggle_gitblame()
    end, { desc = 'Toggle [G]it [B]lame' })
  end,
}

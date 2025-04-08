return {
  'tpope/vim-fugitive',
  config = function()
    local otp = vim.g.option_toggle_prefix
    -- Opening and closing folds
    -- zc (close), zo (open), and za (toggle) operate on one level of folding, at the cursor
    vim.keymap.set('n', otp .. 'gd', '<cmd>Gvdiffsplit!<CR>', { desc = "vimdiff" })
    -- Toggle git blame
    local function toggle_gitblame()
      if vim.bo.filetype == 'fugitiveblame' then
        vim.api.nvim_win_close(0, false)
      else
        vim.cmd('G blame')
      end
    end
    vim.keymap.set('n', otp .. 'gb', function()
      toggle_gitblame()
    end, { desc = "Toggle 'gitblame'" })
  end,
}

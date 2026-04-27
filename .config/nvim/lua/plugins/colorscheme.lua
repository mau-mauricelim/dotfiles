return {
  'navarasu/onedark.nvim',
  lazy = false,    -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    -- Setup if any
    require('onedark').setup({
      style = 'cool',
      -- Highlights from tokyonight.nvim
      highlights = {
        FlashBackdrop = { fg = '#545c7e' },
        Search        = { fg = '#c0caf5', bg = '#3d59a1' },
        IncSearch     = { fg = '#1d202f', bg = '#ff9e64' },
        FlashLabel    = { fg = '#c0caf5', bg = '#ff007c', bold = true },
        MsgArea       = { fg = '#a9b1d6' },
        Special       = { fg = '#2ac3de' },
        Cursor        = { fg = '#24283b', bg = '#c0caf5' },
      },
    })
    -- Load the colorscheme here
    vim.cmd.colorscheme('onedark')
    -- You can configure highlights by doing something like
    vim.cmd.hi('Comment gui=none')
  end,
}

return { -- You can easily change to a different colorscheme.
  -- Change the name of the colorscheme plugin below, and then
  -- change the command in the config to whatever the name of that colorscheme is
  --
  -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`
  'navarasu/onedark.nvim',
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    -- Setup if any
    require('onedark').setup({
      style = 'cool',
      -- Highlights from tokyonight.nvim
      highlights = {
        FlashBackdrop = {
          fg = '#545c7e',
        },
        Search = {
          bg = '#3d59a1',
          fg = '#c0caf5',
        },
        IncSearch = {
          bg = '#ff9e64',
          fg = '#1d202f',
        },
        FlashLabel = {
          bg = '#ff007c',
          bold = true,
          fg = '#c0caf5',
        },
        MsgArea = {
          fg = '#a9b1d6',
        },
        Special = {
          fg = '#2ac3de',
        },
        Cursor = {
          bg = '#c0caf5',
          fg = '#24283b',
        },
      },
    })

    -- Load the colorscheme here
    vim.cmd.colorscheme('onedark')

    -- You can configure highlights by doing something like
    vim.cmd.hi('Comment gui=none')
  end,
}


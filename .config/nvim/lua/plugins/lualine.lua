return { -- statusline
  'nvim-lualine/lualine.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('lualine').setup({
      options = {
        globalstatus = true, -- single statusline for every window - only available in neovim 0.7 and higher
        refresh = { statusline = 100, tabline = 100, winbar = 100 },
      },
      sections = {
        -- stylua: ignore
        lualine_c = {
          {
            'filename',
            path = 1,   -- 0: Just the filename
                        -- 1: Relative path
                        -- 2: Absolute path
                        -- 3: Absolute path, with tilde as the home directory
                        -- 4: Filename and parent dir, with tilde as the home directory
          },
        },
      },
    })
  end,
}
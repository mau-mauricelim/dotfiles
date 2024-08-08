-- NOTE: Enabling scrollbar may cause issues with shift highlight copy paste from terminal
return {
  'petertriho/nvim-scrollbar',
  event = 'VeryLazy',
  dependencies = { 'kevinhwang91/nvim-hlslens' },
  config = function()
    -- Leave only search marks and disable virtual text
    require('scrollbar.handlers.search').setup({
      override_lens = function() end,
    })
    local colors = require('colors')
    require('scrollbar').setup({
      handle = { color = colors.bg0 },
        -- stylua: ignore
        marks = {
            Error  = { color = colors.red },
            Warn   = { color = colors.orange },
            Search = { color = colors.yellow },
            Info   = { color = colors.blue },
            Hint   = { color = colors.cyan },
            Misc   = { color = colors.purple },
        },
      handlers = { search = true }, -- Requires hlslens
    })
  end,
}

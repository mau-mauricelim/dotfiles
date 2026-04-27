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
    require('scrollbar').setup({
      handle = { color = _G.colors.bg0 },
      -- stylua: ignore
      marks = {
          Error  = { color = _G.colors.red },
          Warn   = { color = _G.colors.orange },
          Search = { color = _G.colors.yellow },
          Info   = { color = _G.colors.blue },
          Hint   = { color = _G.colors.cyan },
          Misc   = { color = _G.colors.purple },
      },
      handlers = { search = true }, -- Requires hlslens
    })
  end,
}

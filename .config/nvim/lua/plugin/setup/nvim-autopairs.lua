return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  config = function()
    local Rule = require('nvim-autopairs.rule')
    local npairs = require('nvim-autopairs')
    npairs.setup({
      disable_in_macro = false, -- Disable when recording or executing a macro
      -- Enable fast wrap in insert mode
      fast_wrap = {
        map = '<M-e>',
      },
    })
    -- Disable backtick pair on filetype q or k
    npairs.add_rules({
      Rule('`', '', 'q'),
      Rule('`', '', 'k'),
    })
  end,
}

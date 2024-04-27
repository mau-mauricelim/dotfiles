return {
  'windwp/nvim-autopairs',
  event = "InsertEnter",
  config = function()
    local npairs = require("nvim-autopairs")
    npairs.setup({
      disable_in_macro = false, -- Disable when recording or executing a macro
      -- Enable fast wrap
      fast_wrap = {
        map = '<M-e>',
      }
    })
    -- remove add backtick on filetype q or k
    npairs.get_rules("`")[1].not_filetypes = { "q", "k" }
  end
}
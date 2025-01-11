return {
  'saghen/blink.cmp',
  -- optional: provides snippets for the snippet source
  dependencies = 'rafamadriz/friendly-snippets',
  version = '*',
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' for mappings similar to built-in completion
    -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
    -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
    -- See the full "keymap" documentation for information on defining your own keymap.
    keymap = { preset = 'default' },
    appearance = {
      -- Sets the fallback highlight groups to nvim-cmp's highlight groups
      -- Useful for when your theme doesn't support blink.cmp
      -- Will be removed in a future release
      use_nvim_cmp_as_default = true,
      -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono',
    },
    completion = {
      -- 'prefix' will fuzzy match on the text before the cursor
      -- 'full' will fuzzy match on the text before *and* after the cursor
      -- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
      keyword = { range = 'full' },
      -- Disable auto brackets
      -- NOTE: some LSPs may add auto brackets themselves anyway
      accept = { auto_brackets = { enabled = false } },
      list = { selection = { preselect = true, auto_insert = true } },
      -- or set either per mode via a function
      -- list = { selection = { preselect = function(ctx) return ctx.mode ~= 'cmdline' end } },
    },
  },
}

-- HACK: To use words from all loaded buffers (probably, only listed buffers, to be precise)
-- Type the words that start with the keyword in front of the cursor then
-- hide (default: `<C-e>`) the current completion from blink and
-- use the built-in Neovim (and Vim) completion with `<C-n>`. See :h i_CTRL-N.
-- Limitations:
-- It is a highly built-in feature which doesn't have a good way of utilizing it
-- other than actually simulating pressing `<C-n>`.
-- It is also blocking/synchronous which has noticeable lagging when there is a very
-- large buffer opened (like 10K - 100K lines depending on the machine).

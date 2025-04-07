-- NOTE: Plugins can also be configured to run lua code when they are loaded.
--
-- This is often very useful to both group configuration, as well as handle
-- lazy loading plugins that don't need to be loaded immediately at startup.
--
-- For example, in the following configuration, we use:
--  event = 'VimEnter'
--
-- which loads which-key before all the UI elements are loaded. Events can be
-- normal autocommands events (`:help autocmd-events`).
--
-- Then, because we use the `config` key, the configuration only runs
-- after the plugin has been loaded:
--  config = function() ... end
--
return { -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  event = 'VeryLazy',
  config = function() -- This is the function that runs, AFTER loading
    local wk = require('which-key')
    wk.setup({
      sort = { 'alphanum' },
    })
    -- Document existing key chains
    local otp = vim.g.option_toggle_prefix
    wk.add({
      { '<Leader>/', group = '[/]search' },
      { '<Leader>b', group = '[B]uffer' },
      { '<Leader>c', group = '[C]ode' },
      { '<Leader>d', group = '[D]ocument' },
      { '<Leader>f', group = '[F]ormat' },
      { '<Leader>h', group = '[H]unk' },
      { '<Leader>l', group = '[L]azy*' },
      { '<Leader>n', group = '[N]oice' },
      { '<Leader>o', group = 'Gl[O]b search' },
      { '<Leader>of', group = 'Gl[O]b files' },
      { '<Leader>og', group = 'Gl[O]b grep' },
      { '<Leader>r', group = '[R]ename' },
      { '<Leader>s', group = '[S]earch' },
      { '<Leader>v', group = '[V]irtual' },
      { '<Leader>w', group = '[W]orkspace' },
      { '<Leader>x', group = 'E[X]ecute' },
      { otp .. 'g',  group = 'Toggle git' },
    })
  end,
}

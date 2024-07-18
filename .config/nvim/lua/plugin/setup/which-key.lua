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
    -- Document existing key chains
    wk.add({
      { '<Leader>c', group = '[C]ode' },
      { '<Leader>d', group = '[D]ocument' },
      { '<Leader>r', group = '[R]ename' },
      { '<Leader>s', group = '[S]earch' },
      { '<Leader>w', group = '[W]orkspace' },
      { '<Leader>/', group = '[/]search' },
      { '<Leader>b', group = '[B]uffer' },
      { '<Leader>f', group = '[F]ormat' },
      { '<Leader>g', group = '[G]it' },
      { '<Leader>h', group = '[H]unk' },
      { '<Leader>l', group = '[L]azy*' },
      { '<Leader>n', group = '[N]oice' },
      { '<Leader>p', group = '[P]ersistence' },
      { '<Leader>t', group = '[T]oggle' },
      { '<Leader>v', group = '[V]irtual' },
      { '<Leader>x', group = 'E[X]ecute' },
    })
  end,
}

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
    require('which-key').setup()
    -- Document existing key chains
    -- stylua: ignore
    require('which-key').register({
      ['<Leader>c'] = { name = '[C]ode',              _ = 'which_key_ignore' },
      ['<Leader>d'] = { name = '[D]ocument',          _ = 'which_key_ignore' },
      ['<Leader>r'] = { name = '[R]ename',            _ = 'which_key_ignore' },
      ['<Leader>s'] = { name = '[S]earch',            _ = 'which_key_ignore' },
      ['<Leader>w'] = { name = '[W]orkspace',         _ = 'which_key_ignore' },
      ['<Leader>/'] = { name = '[/]search',           _ = 'which_key_ignore' },
      ['<Leader>b'] = { name = '[B]uffer',            _ = 'which_key_ignore' },
      ['<Leader>f'] = { name = '[F]ormat',            _ = 'which_key_ignore' },
      ['<Leader>g'] = { name = '[G]it',               _ = 'which_key_ignore' },
      ['<Leader>h'] = { name = '[H]unk',              _ = 'which_key_ignore' },
      ['<Leader>l'] = { name = '[L]azy*, Lua, Lines', _ = 'which_key_ignore' },
      ['<Leader>n'] = { name = '[N]oice',             _ = 'which_key_ignore' },
      ['<Leader>p'] = { name = '[P]ersistence',       _ = 'which_key_ignore' },
      ['<Leader>t'] = { name = '[T]oggle',            _ = 'which_key_ignore' },
      ['<Leader>v'] = { name = '[V]irtual',           _ = 'which_key_ignore' },
      ['<Leader>x'] = { name = 'E[X]ecute',           _ = 'which_key_ignore' },
    })
  end,
}

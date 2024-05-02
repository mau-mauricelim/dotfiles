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
      ['<leader>c'] = { name = '[C]ode',          _ = 'which_key_ignore' },
      ['<leader>d'] = { name = '[D]ocument',      _ = 'which_key_ignore' },
      ['<leader>r'] = { name = '[R]ename',        _ = 'which_key_ignore' },
      ['<leader>s'] = { name = '[S]earch',        _ = 'which_key_ignore' },
      ['<leader>w'] = { name = '[W]orkspace',     _ = 'which_key_ignore' },
      ['<leader>/'] = { name = '[/]search',       _ = 'which_key_ignore' },
      ['<leader>b'] = { name = '[B]uffer',        _ = 'which_key_ignore' },
      ['<leader>f'] = { name = '[F]ormat',        _ = 'which_key_ignore' },
      ['<leader>g'] = { name = '[G]it',           _ = 'which_key_ignore' },
      ['<leader>h'] = { name = '[H]unk',          _ = 'which_key_ignore' },
      ['<leader>l'] = { name = '[L]azy* and Lua', _ = 'which_key_ignore' },
      ['<leader>n'] = { name = '[N]oice',         _ = 'which_key_ignore' },
      ['<leader>p'] = { name = '[P]ersistence',   _ = 'which_key_ignore' },
      ['<leader>t'] = { name = '[T]oggle',        _ = 'which_key_ignore' },
      ['<leader>v'] = { name = '[V]irtual',       _ = 'which_key_ignore' },
      ['<leader>x'] = { name = 'E[X]ecute',       _ = 'which_key_ignore' },
    })
  end,
}

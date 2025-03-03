return { -- Autocompletion
  'hrsh7th/nvim-cmp',
  -- event = 'InsertEnter',
  event = 'VeryLazy', -- Completion for cmdline cannot use InsertEnter
  dependencies = {
    -- Snippet Engine & its associated nvim-cmp source
    {
      'L3MON4D3/LuaSnip',
      build = (function()
        -- Build Step is needed for regex support in snippets
        -- This step is not supported in many windows environments
        -- Remove the below condition to re-enable on windows
        if vim.fn.has('win32') == 1 or vim.fn.executable('make') == 0 then
          return
        end
        return 'make install_jsregexp'
      end)(),
    },
    'saadparwaiz1/cmp_luasnip',

    -- Adds other completion capabilities.
    --  nvim-cmp does not ship with all sources by default. They are split
    --  into multiple repos for maintenance purposes.
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    -- Completion for cmdline
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-buffer',

    -- If you want to add a bunch of pre-configured snippets,
    --    you can use this plugin to help you. It even has snippets
    --    for various frameworks/libraries/etc. but you will have to
    --    set up the ones that are useful for you.
    -- 'rafamadriz/friendly-snippets',

    -- https://www.npmjs.com/package/@jo.shinonome/qls
    -- q language server
    -- - autocompletion
    -- - definitionProvider
    -- - referencesProvider
    'hrsh7th/cmp-vsnip',
    'hrsh7th/vim-vsnip',
  },
  config = function()
    -- See `:help cmp`
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    luasnip.config.setup()

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = { completeopt = 'menu,menuone,noselect,noinsert' },

      -- For an understanding of why these mappings were
      -- chosen, you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      -- stylua: ignore
      mapping = cmp.mapping.preset.insert({
        -- Disable Up/Down keys in insert mode for consistency
        ['<Up>'] = { i = function(fallback) cmp.close() fallback() end },
        ['<Down>'] = { i = function(fallback) cmp.close() fallback() end },

        -- Select the [n]ext item
        ['<C-n>'] = cmp.mapping.select_next_item(),
        -- Select the [p]revious item
        ['<C-p>'] = cmp.mapping.select_prev_item(),

        -- Accept ([y]es) the completion.
        --  This will auto-import if your LSP supports it.
        --  This will expand snippets if the LSP sent a snippet.
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),

        -- Manually trigger a completion from nvim-cmp.
        --  Generally you don't need this, because nvim-cmp will display
        --  completions whenever it has completion options available.
        ['<C-Space>'] = cmp.mapping.complete(),

        -- Think of <c-l> as moving to the right of your snippet expansion.
        --  So if you have a snippet that's like:
        --  function $name($args)
        --    $body
        --  end
        --
        -- <c-l> will move you to the right of each of the expansion locations.
        -- <c-h> is similar, except moving you backwards.
        ['<C-l>'] = cmp.mapping(function()
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { 'i', 's' }),
        ['<C-h>'] = cmp.mapping(function()
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { 'i', 's' }),
      }),
      sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
        -- qls
        { name = 'vsnip' },
        { name = 'buffer' },
      },
    })

    -- Completion for cmdline
    -- Ctrl-E to close completion
    local custom_mapping = cmp.mapping.preset.cmdline({
      -- Select the [n]ext/[p]revious item
      -- in the cmd history if there is no selected entry (default)
      -- in the cmp list if there is a selected entry (Tab)
      ['<C-n>'] = {
        c = function(fallback)
          if cmp.visible() and cmp.get_selected_entry() ~= nil then
            cmp.select_next_item()
          else
            cmp.close()
            fallback()
          end
        end,
      },
      ['<C-p>'] = {
        c = function(fallback)
          if cmp.visible() and cmp.get_selected_entry() ~= nil then
            cmp.select_prev_item()
          else
            cmp.close()
            fallback()
          end
        end,
      },
    })
    -- `/` cmdline setup.
    cmp.setup.cmdline('/', {
      mapping = custom_mapping,
      sources = {
        { name = 'buffer' },
      },
    })
    -- `:` cmdline setup.
    cmp.setup.cmdline(':', {
      mapping = custom_mapping,
      sources = cmp.config.sources({
        { name = 'path' },
      }, {
        {
          name = 'cmdline',
          option = {
            ignore_cmds = { 'Man', '!', 'read', 'write' },
          },
          -- HACK: fix for `:r !` or `:w !`, still hangs if you press space after `!`
          -- https://github.com/hrsh7th/cmp-cmdline/issues/112
          -- keyword_pattern = [[\!\@<!\w*]],
        },
      }),
    })
  end,
}

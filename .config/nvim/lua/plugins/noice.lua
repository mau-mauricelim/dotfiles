return { -- UI for messages, cmdline and the popupmenu
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = {
    -- If you lazy-load any plugin below, make sure to add proper `module='...'` entries
    'MunifTanjim/nui.nvim',
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    -- 'rcarriga/nvim-notify',
  },
  config = function()
    local noice = require('noice')
    noice.setup({
      lsp = {
        -- Override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
        },
        signature = { enabled = false },
      },
      -- Enable a preset for easier configuration
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
      },
      -- You can add any custom commands below that will be available with `:Noice command`
      commands = {
        popup = {
          -- options for the message history that you get with `:Noice`
          view = 'popup',
          opts = { enter = true, format = 'details' },
          filter = {
            any = {
              { event = 'notify' },
              { error = true },
              { warning = true },
              { event = 'msg_show', kind = { '' } },
              { event = 'lsp', kind = 'message' },
            },
          },
        },
      },
    })
    -- Dismiss Noice message
    vim.keymap.set('n', '<Leader>nd', '<cmd>NoiceDismiss<CR>', { desc = '[N]oice [D]ismiss message' })
    -- Noice popup view
    vim.keymap.set('n', '<Leader>np', '<cmd>NoicePopup<CR>', { desc = '[N]oice [P]opup history' })
    -- Noice default view
    vim.keymap.set('n', '<Leader>nh', '<cmd>Noice<CR>', { desc = '[N]oice [H]istory' })
    -- Override the default behaviour in vim.lua
    vim.keymap.set(
      'n',
      '<Esc>',
      '<cmd>NoiceDismiss<CR><cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>',
      { desc = 'Noice Dismiss / Redraw / Clear hlsearch / Diff Update', silent = true }
    )
    -- Normal messages
    vim.keymap.set('n', '<Leader>nm', '<cmd>messages<CR>', { desc = '[N]ormal [M]essages' })

    local status_ok, lualine = pcall(require, 'lualine')
    if status_ok then
      lualine.setup({
        sections = {
          lualine_x = {
            -- Show @recording messages in the statusline
            {
              noice.api.statusline.mode.get,
              cond = noice.api.statusline.mode.has,
              color = { fg = '#ff9e64' },
            },
            {
              noice.api.status.command.get,
              cond = noice.api.status.command.has,
              color = { fg = '#ff9e64' },
            },
            {
              'fileformat',
              icons_enabled = true,
              symbols = {
                unix = 'LF',
                dos = 'CRLF',
                mac = 'CR',
              },
            },
          },
        },
      })
    end
  end,
}

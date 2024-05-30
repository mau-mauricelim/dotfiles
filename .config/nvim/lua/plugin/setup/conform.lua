return { -- Autoformat
  'stevearc/conform.nvim',
  -- event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<Leader>fb',
      function()
        vim.notify('Formatting buffer')
        require('conform').format({ async = true, lsp_fallback = true })
        -- pcall(TrimEndLines)
      end,
      mode = { 'n', 'v' },
      desc = '[F]ormat [b]uffer',
    },
  },
  opts = {
    -- Define your formatters
    -- stylua: ignore
    formatters_by_ft = {
      lua    = { 'stylua' },
      -- Conform can also run multiple formatters sequentially
      python = { 'isort', 'black' },
      shell  = { 'shfmt', 'shellcheck' },
      bash   = { 'shfmt', 'shellcheck' },
      zsh    = { 'shfmt', 'shellcheck' },
      --
      -- You can use a sub-list to tell conform to run *until* a formatter is found
      javascript = { { 'prettierd', 'prettier' } },
      html       = { { 'prettierd', 'prettier' } },
      json       = { { 'prettierd', 'prettier' } },
      yaml       = { { 'prettierd', 'prettier' } },
      markdown   = { { 'prettierd', 'prettier' } },
    },
    notify_on_error = false,
    -- Set up format-on-save
    -- format_on_save = { timeout_ms = 500, lsp_fallback = true },
    -- Customize formatters
    formatters = {
      shfmt = {
        prepend_args = { '-i', '2' },
      },
    },
  },
  init = function()
    -- If you want the formatexpr, here is the place to set it
    vim.o.formatexpr = 'v:lua.require"conform".formatexpr()'
  end,
}

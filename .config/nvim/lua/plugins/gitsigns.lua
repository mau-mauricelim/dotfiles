-- Here is a more advanced example where we pass configuration
-- options to `gitsigns.nvim`. This is equivalent to the following lua:
--    require('gitsigns').setup({ ... })
--
-- See `:help gitsigns` to understand what the configuration keys do
-- stylua: ignore
return { -- Adds git related signs to the gutter, as well as utilities for managing changes
  'lewis6991/gitsigns.nvim',
  event = 'VeryLazy',
  config = function()
    require('gitsigns').setup({
      signs = {
        add          = { text = '+' },
        change       = { text = '~' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, {expr=true})

        map('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, {expr=true})

        -- Actions
        gs.stage_hunk_visual = function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end
        gs.reset_hunk_visual = function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end
        gs.blame_line_full   = function() gs.blame_line{full=true} end
        gs.diffthis_tilde    = function() gs.diffthis('~') end
        map("n", "]h",         gs.next_hunk,                 { desc = 'Next Hunk' })
        map("n", "[h",         gs.prev_hunk,                 { desc = 'Prev Hunk' })
        map('n', '<Leader>hs', gs.stage_hunk,                { desc = '[H]unk [S]tage' })
        map('n', '<Leader>hr', gs.reset_hunk,                { desc = '[H]unk [R]eset' })
        map('v', '<Leader>hs', gs.stage_hunk_visual,         { desc = '[H]unk [S]tage' })
        map('v', '<Leader>hr', gs.reset_hunk_visual,         { desc = '[H]unk [R]eset' })
        map('n', '<Leader>hS', gs.stage_buffer,              { desc = '[S]tage buffer' })
        map('n', '<Leader>hu', gs.undo_stage_hunk,           { desc = '[H]unk stage [U]ndo' })
        map('n', '<Leader>hR', gs.reset_buffer,              { desc = '[R]eset buffer' })
        map('n', '<Leader>hp', gs.preview_hunk,              { desc = '[H]unk [P]review' })
        map('n', '<Leader>hb', gs.blame_line_full,           { desc = 'Git [B]lame line' })
        map('n', '<Leader>tb', gs.toggle_current_line_blame, { desc = '[T]oggle Git [B]lame line' })
        map('n', '<Leader>hd', gs.diffthis,                  { desc = 'Preview [D]iff' })
        map('n', '<Leader>hD', gs.diffthis_tilde,            { desc = 'Preview [D]iff ~' })
        map('n', '<Leader>td', gs.toggle_deleted,            { desc = '[T]oggle [D]eleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
      end,
    })
  end,
}

return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  -- stylua: ignore
  config = function()
    local harpoon = require('harpoon')
    harpoon.setup()
    vim.keymap.set('n', '<Leader>a', function() harpoon:list():add(); vim.notify('Added ' .. vim.fn.expand('%') .. ' to harpoon list') end, { desc = '[A]dd file to harpoon list' })
    vim.keymap.set('n', '<C-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Toggle harpoon list' })
    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '[a', function() harpoon:list():prev() end, { desc = 'Next H[a]rpoon buffer' })
    vim.keymap.set('n', ']a', function() harpoon:list():next() end, { desc = 'Previous H[a]rpoon buffer' })
  end,
}

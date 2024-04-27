return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require('harpoon')
    harpoon.setup()

    vim.keymap.set('n', '<leader>a', function() harpoon:list():add(); vim.notify('Added ' .. vim.fn.expand('%') .. ' to harpoon list') end, { desc = '[A]dd file to harpoon list' })
    vim.keymap.set('n', '<C-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Toggle harpoon list' })
    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '[h', function() harpoon:list():prev() end, { desc = 'Next [H]arpoon buffer' })
    vim.keymap.set('n', ']h', function() harpoon:list():next() end, { desc = 'Previous [H]arpoon buffer' })
  end,
}
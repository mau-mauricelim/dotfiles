return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  -- stylua: ignore
  config = function()
    local harpoon = require('harpoon')
    harpoon.setup()

    vim.keymap.set('n', '<Leader>a', function() harpoon:list():add(); vim.notify('Added ' .. vim.fn.expand('%') .. ' to harpoon list') end, { desc = '[A]dd file to harpoon list' })
    vim.keymap.set('n', '<C-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Toggle harpoon list' })
    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '[h', function() harpoon:list():prev() end, { desc = 'Next [H]arpoon buffer' })
    vim.keymap.set('n', ']h', function() harpoon:list():next() end, { desc = 'Previous [H]arpoon buffer' })

    -- Basic telescope configuration
    local conf = require('telescope.config').values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)

      end

      require('telescope.pickers').new({}, {
        prompt_title = 'Harpoon',
        finder = require('telescope.finders').new_table({
          results = file_paths,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
      }):find()
    end

    vim.keymap.set('n', '<Leader>sa', function() toggle_telescope(harpoon:list()) end,
      { desc = '[S]earch H[a]rpoon list' })
  end,
}

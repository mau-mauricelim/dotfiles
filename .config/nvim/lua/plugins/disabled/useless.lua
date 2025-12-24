-- stylua: ignore
return { -- Useless plugins
  {
    'Eandrju/cellular-automaton.nvim',
    -- NOTE: You can close animation window with one of: `q`/`<Esc>`/`<CR>`
    keys = {
      { '<Leader>fmlr', mode = { 'n' }, '<cmd>CellularAutomaton make_it_rain<CR>', desc = 'Make it Rain' },
      { '<Leader>fmlg', mode = { 'n' }, '<cmd>CellularAutomaton game_of_life<CR>', desc = 'Game of Life' },
    },
    opts = {},
  },
  {
    'tamton-aquib/duck.nvim',
    keys = {
      {
        '<Leader>fmld',
        mode = { 'n' },
        function()
          local char = { '🦆', 'ඞ', '🦀', '🐈', '🐎', '🦖', '🐤' }
          require('duck').hatch(char[math.random(#char)], math.random() + math.random(0, 9))
        end,
        desc = 'Release a duck',
      },
      { '<Leader>fmlc', mode = { 'n' }, function() require('duck').cook() end, desc = 'Cook a duck' },
      { '<Leader>fmla', mode = { 'n' }, function() require('duck').cook_all() end, desc = 'Cook all ducks' },
    },
    opts = {},
  },
}

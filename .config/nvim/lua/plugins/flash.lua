return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {
    modes = {
      -- options used when flash is activated through
      -- `f`, `F`, `t`, `T`, `;` and `,` motions
      char = {
        -- The direction for `prev` and `next` is determined by the motion.
        -- `left` and `right` are always left and right.
        char_actions = function(motion)
          return {
            [';'] = 'right', -- set to `right` to always go right
            [','] = 'left', -- set to `left` to always go left
            -- clever-f style
            [motion:lower()] = 'next',
            [motion:upper()] = 'prev',
            -- jump2d style: same case goes next, opposite case goes prev
            -- [motion] = "next",
            -- [motion:match("%l") and motion:upper() or motion:lower()] = "prev",
          }
        end,
      },
    },
  },
  -- stylua: ignore
  keys = {
    { '<C-f>', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' },
    { 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash Treesitter' },
    { 'r', mode = 'o', function() require('flash').remote() end, desc = 'Remote Flash' },
    { 'R', mode = { 'o', 'x' }, function() require('flash').treesitter_search() end, desc = 'Treesitter Search' },
    { '<C-s>', mode = { 'c' }, function() require('flash').toggle() end, desc = 'Toggle Flash Search' },
  },
}

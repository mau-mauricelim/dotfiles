return { -- Find And Replace plugin for neovim
  'MagicDuck/grug-far.nvim',
  keys = {
    {
      '<Leader>fr',
      mode = { 'n' },
      function()
        require('grug-far').open({ prefills = { paths = vim.fn.expand('%') } })
      end,
      desc = '[F]ind and [R]eplace in current file',
    },
    {
      '<Leader>gfw',
      mode = { 'n' },
      function()
        require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } })
      end,
      desc = '[G]rug-[F]ar search current [W]ord under the cursor',
    },
    {
      '<Leader>gfv',
      mode = { 'v' },
      [[:<C-u>lua require('grug-far').with_visual_selection({ prefills = { paths = vim.fn.expand("%") } })<CR>]],
      desc = '[G]rug-[F]ar search current visual selection in current file',
    },
  },
  opts = {},
}

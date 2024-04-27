-- Useful to search files with different path
-- :Files [PATH]
return { -- fzf/Vim integration
  'junegunn/fzf.vim',
  event = 'VeryLazy',
  -- fzf is a general-purpose command-line fuzzy finder.
  dependencies = { 'junegunn/fzf' },
  config = function()
    -- Customizing commands for fzf.vim
    -- stylua: ignore
    vim.cmd('command! -bang -nargs=* Rg call ' ..
      'fzf#vim#grep("rg --hidden --glob \'!.git\' --column --line-number --no-heading --color=always --smart-case' ..
      ' -- ".fzf#shellescape(<q-args>), fzf#vim#with_preview(), <bang>0)')
  end,
}
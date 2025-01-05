return {
  'mbbill/undotree',
  cmd = {
    'UndotreeToggle',
  },
  keys = {
    { vim.g.option_toggle_prefix .. 'u', vim.cmd.UndotreeToggle },
  },
}

return {
  'knubie/vim-kitty-navigator',
  -- Enable if using kitty
  enabled = os.getenv('KITTY_WINDOW_ID') ~= nil,
}

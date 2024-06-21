-- Pull in the wezterm API
local wezterm = require('wezterm')
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.default_prog = { 'wsl', '--cd', '~' }
config.font = wezterm.font {
  family = 'JetBrains Mono',
  -- Disable ligatures in most fonts
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
}
config.font_size = 16
config.window_padding = { left = 5, right = 5, top = 0, bottom = 0 }
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.selection_word_boundary = ',│`|:"\' ()[]{}<>\t'
config.enable_scroll_bar = true
config.cursor_thickness = 2
config.audible_bell = 'Disabled'

-- For example, changing the color scheme:
config.color_scheme = 'Campbell (Gogh)'
config.color_schemes = {
  ['Campbell (Gogh)'] = {
    scrollbar_thumb = '9f9f9f',
  },
}

-- Mouse bindings
config.mouse_bindings = {
  -- Right-click to paste
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ''
      if has_selection then
        window:perform_action(act.CopyTo('ClipboardAndPrimarySelection'), pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act({ PasteFrom = 'Clipboard' }), pane)
      end
    end),
  },

  -- Single Left Up: Focus window does not copy text
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.Multiple({
      act.ClearSelection,
    }),
  },
  -- Single Left Drag to Highlight and Copy
  {
    event = { Drag = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.Multiple({
      act.ExtendSelectionToMouseCursor('Cell'),
      act.CopyTo('ClipboardAndPrimarySelection'),
    }),
  },
  -- Double click to Copy
  {
    event = { Up = { streak = 2, button = 'Left' } },
    mods = 'NONE',
    action = act.Multiple({
      act.CopyTo('ClipboardAndPrimarySelection'),
      act.ClearSelection,
    }),
  },
  -- Triple click line to Copy
  {
    event = { Up = { streak = 3, button = 'Left' } },
    mods = 'NONE',
    action = act.Multiple({
      act.CopyTo('ClipboardAndPrimarySelection'),
      act.ClearSelection,
    }),
  },
  -- CTRL-Click to open hyperlink
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
  -- NOTE that binding only the 'Up' event can give unexpected behaviors.
  -- Read more below on the gotcha of binding an 'Up' event only.

  -- Scrolling up while holding CTRL increases the font size
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = 'CTRL',
    action = act.IncreaseFontSize,
  },
  -- Scrolling down while holding CTRL decreases the font size
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = 'CTRL',
    action = act.DecreaseFontSize,
  },
}

-- Key bindings
config.keys = {
  -- Paste from the clipboard
  { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
  {
    key = "|",
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = "_",
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
}

-- And finally, return the configuration to wezterm
return config

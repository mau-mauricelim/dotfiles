-- Pull in the wezterm API
local wezterm = require('wezterm')
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.default_prog = { 'wsl', '--cd', '~' }
config.font = wezterm.font('JetBrains Mono')
config.font_size = 16
config.window_padding = { left = 5, right = 5, top = 0, bottom = 0 }
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.selection_word_boundary = ',│`|:"\' ()[]{}<>\t'

-- For example, changing the color scheme:
config.color_scheme = 'Campbell (Gogh)'

-- Mouse bindings
config.mouse_bindings = {
  -- Highlight selection to copy and right-click to paste
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

-- and finally, return the configuration to wezterm
return config

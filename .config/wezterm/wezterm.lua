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
config.enable_scroll_bar = true

-- For example, changing the color scheme:
config.color_scheme = 'Campbell (Gogh)'
config.color_schemes = {
  ['Campbell (Gogh)'] = {
    scrollbar_thumb = '9f9f9f',
  },
}

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

  -- Change the default click behavior so that it only selects
  -- text and doesn't open hyperlinks
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.Multiple({
      act.CopyTo('ClipboardAndPrimarySelection'),
      act.ClearSelection,
    }),
  },
  -- Double click on word
  {
    event = { Up = { streak = 2, button = 'Left' } },
    mods = 'NONE',
    action = act.Multiple({
      act.CopyTo('ClipboardAndPrimarySelection'),
      act.ClearSelection,
    }),
  },
  -- Triple click on line
  {
    event = { Up = { streak = 3, button = 'Left' } },
    mods = 'NONE',
    action = act.Multiple({
      act.CopyTo('ClipboardAndPrimarySelection'),
      act.ClearSelection,
    }),
  },
  -- and make CTRL-Click open hyperlinks
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

-- and finally, return the configuration to wezterm
return config

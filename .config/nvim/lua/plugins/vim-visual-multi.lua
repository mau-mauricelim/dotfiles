return { -- Multiple cursors plugin for vim/neovim
  'mg979/vim-visual-multi',
  branch = 'master',
}

--[ -- Basic usage:
--  - Select words with `Ctrl-N`
--  - Create cursors vertically with `Ctrl-<Down/Up>`
--  - Select one character at a time with `Shift-Arrows`
--  - Press `n`/`N` to get next/previous occurrence
--  - Press `[`/`]` to select next/previous cursor
--  - Press `q` to skip current and get next occurrence
--  - Press `Q` to remove current cursor/selection
--  - Start insert mode with `i`,`a`,`I`,`A`
--
-- Two main modes:
--  - In _cursor mode_ commands work as they would in normal mode
--  - In _extend mode_ commands work as they would in visual mode
--  - Press `Tab` to switch between «cursor» and «extend» mode
--
-- Most vim commands work as expected (motions, `r` to replace characters, `~` to change case, etc). Additionally you can:
--  - Run macros/ex/normal commands at cursors
--  - Align cursors
--  - Transpose selections
--  - Add patterns with regex, or from visual mode
--
-- And more... of course, you can enter insert mode and autocomplete will work.
--
-- Tutorial:
--  - vvmtutor (custom) ]]

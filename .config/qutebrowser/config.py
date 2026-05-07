## INFO: https://www.qutebrowser.org/doc/help/settings.html
## INFO: https://www.ii.com/qutebrowser-configpy/

## Themes
config.source('themes/nord.py')

## This is here so configs done via the GUI are still loaded.
## Remove it to not load settings done via the GUI.
config.load_autoconfig()

## Always restore open sites when qutebrowser is reopened. Without this
## option set, `:wq` (`:quit --save`) needs to be used to save open tabs
## (and restore them), while quitting qutebrowser in any other way will
## not save/restore the session. By default, this will save to the
## session which was last loaded. This behavior can be customized via the
## `session.default_name` setting.
## Type: Bool
c.auto_save.session = True

## Javascript messages to *not* show in the UI, despite a corresponding
## `content.javascript.log_message.levels` setting. Both keys and values
## are glob patterns, with the key matching the location of the error,
## and the value matching the error message. By default, the
## https://web.dev/csp/[Content security policy] violations triggered by
## qutebrowser's stylesheet handling are excluded, as those errors are to
## be expected and can't be easily handled by the underlying code.
## Type: Dict
c.content.javascript.log_message.excludes = {
    'userscript:_qute_stylesheet': ['*Refused to apply inline style because it violates the following Content Security Policy directive: *'],
    'userscript:_qute_js': ['*TrustedHTML*']
}

## Editor (and arguments) to use for the `edit-*` commands. The following
## placeholders are defined:  * `{file}`: Filename of the file to be
## edited. * `{line}`: Line in which the caret is found in the text. *
## `{column}`: Column in which the caret is found in the text. *
## `{line0}`: Same as `{line}`, but starting from index 0. * `{column0}`:
## Same as `{column}`, but starting from index 0.
## Type: ShellCommand
c.editor.command = ['alacritty', '-e', 'nvim', '{file}', '-c', 'normal {line}G{column0}l']

## Automatically enter insert mode if an editable element is focused
## after loading the page.
## Type: Bool
c.input.insert_mode.auto_load = True

## How to behave when the last tab is closed. If the
## `tabs.tabs_are_windows` setting is set, this is ignored and the
## behavior is always identical to the `close` value.
## Type: String
## Valid values:
##   - ignore: Don't do anything.
##   - blank: Load a blank page.
##   - startpage: Load the start page.
##   - default-page: Load the default page.
##   - close: Close the window.
c.tabs.last_close = 'blank'

## Maximum width (in pixels) of tabs (-1 for no maximum). This setting
## only applies when tabs are horizontal. This setting does not apply to
## pinned tabs, unless `tabs.pinned.shrink` is False. This setting may
## not apply properly if max_width is smaller than the minimum size of
## tab contents, or smaller than tabs.min_width.
## Type: Int
c.tabs.max_width = 200

## Page to open if :open -t/-b/-w is used without URL. Use `about:blank`
## for a blank page.
## Type: FuzzyUrl
c.url.default_page = 'about:blank'

## Search engines which can be used via the address bar.  Maps a search
## engine name (such as `DEFAULT`, or `ddg`) to a URL with a `{}`
## placeholder. The placeholder will be replaced by the search term, use
## `{{` and `}}` for literal `{`/`}` braces.  The following further
## placeholds are defined to configure how special characters in the
## search terms are replaced by safe characters (called 'quoting'):  *
## `{}` and `{semiquoted}` quote everything except slashes; this is the
## most   sensible choice for almost all search engines (for the search
## term   `slash/and&amp` this placeholder expands to `slash/and%26amp`).
## * `{quoted}` quotes all characters (for `slash/and&amp` this
## placeholder   expands to `slash%2Fand%26amp`). * `{unquoted}` quotes
## nothing (for `slash/and&amp` this placeholder   expands to
## `slash/and&amp`). * `{0}` means the same as `{}`, but can be used
## multiple times.  The search engine named `DEFAULT` is used when
## `url.auto_search` is turned on and something else than a URL was
## entered to be opened. Other search engines can be used by prepending
## the search engine name to the search term, e.g. `:open google
## qutebrowser`.
## Type: Dict
c.url.searchengines = {
    'DEFAULT': 'https://www.google.com/search?q={}',
    'yt': 'https://www.youtube.com/results?search_query={}',
}

## Page(s) to open at the start.
## Type: List of FuzzyUrl, or FuzzyUrl
c.url.start_pages = ['about:blank']

## Bindings for normal mode
config.bind('<Alt-Left>', 'back --quiet')
config.bind('<Alt-Right>', 'forward --quiet')
config.bind('<Alt-r>', 'config-source ;; message-info "Config reloaded!"')
config.bind('<Ctrl-Alt-p>', 'nop')
config.bind('<Ctrl-F>', 'cmd-set-text /')
config.bind('<Ctrl-Shift-P>', 'tab-pin')
config.bind('<Ctrl-Shift-PgDown>', 'tab-move +')
config.bind('<Ctrl-Shift-PgUp>', 'tab-move -')
config.bind('<Ctrl-Shift-R>', 'reload --force')
config.bind('<Ctrl-p>', 'print')
config.bind('<Ctrl-r>', 'reload')
config.bind('<Ctrl-s>', 'nop')
config.bind('<F12>', 'devtools')
config.bind('?', 'cmd-set-text /')
config.bind('D', 'tab-close')
config.bind('H', 'tab-prev')
config.bind('J', 'back --quiet')
config.bind('K', 'forward --quiet')
config.bind('L', 'tab-next')
config.bind('R', 'reload')
config.bind('U', 'undo')
config.bind('[b', 'tab-prev')
config.bind(']b', 'tab-next')
config.bind('d', 'scroll-page 0 0.5')
config.bind('gH', 'tab-move -')
config.bind('gJ', 'nop')
config.bind('gK', 'nop')
config.bind('gL', 'tab-move +')
config.bind('r', 'nop')
config.bind('u', 'scroll-page 0 -0.5')

## Bindings for insert mode
config.bind('<Escape>', 'fake-key <Escape> ;; mode-leave', mode='insert')

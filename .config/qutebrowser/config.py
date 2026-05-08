## INFO: https://www.qutebrowser.org/doc/help/settings.html
## INFO: https://www.ii.com/qutebrowser-configpy/

config.source('themes/nord.py')

config.load_autoconfig()

c.auto_save.session = True

c.content.javascript.log_message.excludes = {
    'userscript:_qute_stylesheet': ['*Refused to apply inline style because it violates the following Content Security Policy directive: *'],
    'userscript:_qute_js': ['*TrustedHTML*']
}

c.editor.command = ['alacritty', '-e', 'nvim', '{file}', '-c', 'normal {line}G{column0}l']

c.input.insert_mode.auto_load = True

c.tabs.indicator.width = 1

c.tabs.last_close = 'blank'

c.tabs.max_width = 200

c.tabs.padding = {'top': 2, 'bottom': 2, 'left': 5, 'right': 5}

c.url.default_page = 'about:blank'

c.url.searchengines = {
    'DEFAULT': 'https://www.google.com/search?q={}',
    'yt': 'https://www.youtube.com/results?search_query={}',
    'kx': 'https://google.com/search?q=site:https://code.kx.com+{}',
    'q': 'https://code.kx.com/q?q={}'
}

c.url.start_pages = ['about:blank']

## Bindings for normal mode
config.bind('<Alt-Left>', 'back --quiet')
config.bind('<Alt-Right>', 'forward --quiet')
config.bind('<Alt-R>', 'config-source ;; message-info "Config reloaded!"')
config.bind('<Ctrl-Alt-p>', 'nop')
config.bind('<Ctrl-F>', 'cmd-set-text /')
config.bind('<Ctrl-Shift-P>', 'tab-pin')
config.bind('<Ctrl-Shift-PgDown>', 'tab-move +')
config.bind('<Ctrl-Shift-PgUp>', 'tab-move -')
config.bind('<Ctrl-Shift-R>', 'reload --force')
config.bind('<Ctrl-P>', 'print')
config.bind('<Ctrl-R>', 'reload')
config.bind('<Ctrl-S>', 'nop')
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

# config.bind('gO', 'cmd-set-text :open -t -r {url:pretty}')
# config.bind('go', 'cmd-set-text :open {url:pretty}')

## Bindings for insert mode
config.bind('<Escape>', 'fake-key <Escape> ;; mode-leave', mode='insert')

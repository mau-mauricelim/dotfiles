-- Extend and create a/i textobjects
require('mini.ai').setup()

-- Show next key clues
local miniclue = require('mini.clue')
require('mini.clue').setup({
    triggers = {
        -- Leader triggers
        { mode = 'n', keys = '<Leader>' },
        { mode = 'x', keys = '<Leader>' },

        -- Built-in completion
        { mode = 'i', keys = '<C-x>' },

        -- `g` key
        { mode = 'n', keys = 'g' },
        { mode = 'x', keys = 'g' },

        -- Marks
        { mode = 'n', keys = "'" },
        { mode = 'n', keys = '`' },
        { mode = 'x', keys = "'" },
        { mode = 'x', keys = '`' },

        -- Registers
        { mode = 'n', keys = '"' },
        { mode = 'x', keys = '"' },
        { mode = 'i', keys = '<C-r>' },
        { mode = 'c', keys = '<C-r>' },

        -- Window commands
        { mode = 'n', keys = '<C-w>' },

        -- `z` key
        { mode = 'n', keys = 'z' },
        { mode = 'x', keys = 'z' },
    },

    clues = {
        -- Enhance this by adding descriptions for <Leader> mapping groups
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows(),
        miniclue.gen_clues.z(),
    },
})

-- Comment lines with Ctrl+/
require('mini.comment').setup({
    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
        -- Toggle comment (like `gcip` - comment inner paragraph) for both
        -- Normal and Visual modes
        comment = '<C-_>',

        -- Toggle comment on current line
        comment_line = '<C-_>',

        -- Toggle comment on visual selection
        comment_visual = '<C-_>',

        -- Define 'comment' textobject (like `dgc` - delete whole comment block)
        -- Works also in Visual mode if mapping differs from `comment_visual`
        textobject = '<C-_>',
    },
})

-- Autocompletion and signature help plugin
require('mini.completion').setup()

-- Automatic highlighting of word under cursor
require('mini.cursorword').setup()

-- Highlight patterns in text
--[[ 
local hipatterns = require('mini.hipatterns')
hipatterns.setup({
    highlighters = {
        -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
        fixme = { pattern = {'%f[%w]()FIXME()%f[%W]', '%f[%w]()Fixme()%f[%W]', '%f[%w]()fixme()%f[%W]' }, 
                    group = 'MiniHipatternsFixme' },
        hack  = { pattern = {'%f[%w]()HACK()%f[%W]',  '%f[%w]()Hack()%f[%W]',  '%f[%w]()hack()%f[%W]'  }, 
                    group = 'MiniHipatternsHack'  },
        todo  = { pattern = {'%f[%w]()TODO()%f[%W]',  '%f[%w]()Todo()%f[%W]',  '%f[%w]()todo()%f[%W]'  }, 
                    group = 'MiniHipatternsTodo'  },
        note  = { pattern = {'%f[%w]()NOTE()%f[%W]',  '%f[%w]()Note()%f[%W]',  '%f[%w]()note()%f[%W]'  }, 
                    group = 'MiniHipatternsNote'  },
        
        -- Highlight hex color strings (`#rrggbb`) using that color
        hex_color = hipatterns.gen_highlighter.hex_color(),
    },
})
--]]

-- Usage:
-- Todo matches on any text that starts with one of your defined keywords (or alt) followed by a colon:

-- Examples:
-- FIX: Bug found
-- WARN: You've been warned
-- HACK: What the hack!
-- TODO: I'll do it later...
-- NOTE: Adding a note
-- PERF: This is perfect!
-- TEST: All unit tests passed!

require("todo-comments").setup({
    -- keywords recognized as todo comments
    keywords = {
        FIX = {
            icon = " ", -- icon used for the sign, and in search results
            color = "error", -- can be a hex color, or a named color (see below)
            alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
            -- signs = false, -- configure signs for some keywords individually
        },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        HACK = { icon = " ", color = "hack" },
        PERF = { icon = " ", color = "perf", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        TODO = { icon = " ", color = "todo" },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
    },
    -- list of named colors where we try to extract the guifg from the
    -- list of highlight groups or use the hex color if hl not found as a fallback
    colors = {
        -- based on onedark.nvim "cool" style colors
        error   = { "#EF5F6B" }, -- red
        warning = { "#D99A5E" }, -- orange
        hack    = { "#EBC275" }, -- yellow
        perf    = { "#97CA72" }, -- green
        todo    = { "#5AB0F6" }, -- blue
        hint    = { "#4DBDCB" }, -- cyan
        test    = { "#CA72E4" }, -- purple
        default = { "#7D899F" }, -- light grey
    },
})

vim.keymap.set("n", "t]", function()
    require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "t[", function()
    require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

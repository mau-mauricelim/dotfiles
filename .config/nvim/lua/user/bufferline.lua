require('bufferline').setup {}
vim.keymap.set("n", "<leader>b]", "<cmd>BufferLineCycleNext<CR>", { silent = true })
vim.keymap.set("n", "<leader>b[", "<cmd>BufferLineCyclePrev<CR>", { silent = true })

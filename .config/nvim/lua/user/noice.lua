-- Dismiss Noice Message
vim.keymap.set("n", "<leader>nd", "<cmd>NoiceDismiss<CR>", {desc = "Dismiss Noice Message"})

require("noice").setup({
  routes = {
    {
      view = "split",
      filter = { event = "msg_show", min_height = 1 },
    },
  },
})

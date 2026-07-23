vim.g.mapleader = " "
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)

vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function(args)
    vim.keymap.set("n", "<Tab>", "<CR>", {
      buffer = args.buf,
      remap = true,
      silent = true,
    })

    vim.keymap.set("n", "<S-Tab>", "-", {
      buffer = args.buf,
      remap = true,
      silent = true,
    })
  end,
})

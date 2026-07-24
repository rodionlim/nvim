
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 75
vim.g.netrw_altv = 1
vim.o.equalalways = false
vim.g.netrw_bufsettings = "noma nomod nu rnu nobl nowrap ro"

vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        vim.keymap.set("n", "<Tab>", "<CR>", { remap = true, buffer = true})
        vim.keymap.set("n", "<S-Tab>", "-", { remap = true, buffer = true})
    end,
})

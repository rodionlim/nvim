vim.g.mapleader = " "

-- File explorer
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)
vim.keymap.set("n", "<leader>cD", function()
    local dir = vim.b.netrw_curdir -- netrw browser buffer
    if not dir then
        local name = vim.api.nvim_buf_get_name(0)
        if vim.fn.isdirectory(name) == 1 then
            dir = name
        elseif name ~= '' then
            dir = vim.fn.fnamemodify(name, ':h') -- normal file buffer
        end
    end
    if dir then
        vim.fn.chdir(dir)
        vim.notify('cmd: ' .. dir)
    else
        vim.notify('No directory for this buffer', vim.log.levels.WARN)
    end
end, { desc = 'cd to buffer dir' })

-- Commenting
vim.keymap.set('n', '<C-_>', 'gcc', { remap = true })
vim.keymap.set('n', '<C-/>', 'gcc', { remap = true })
vim.keymap.set('n', '<C-_>', 'gc', { remap = true })
vim.keymap.set('n', '<C-/>', 'gc', { remap = true })

-- Highlighting
vim.keymap.set('n', '<Esc>', ':noh<CR>', { silent = true }) -- cancel highlights with escape

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

-- macOS terminals commonly encode Option-Right/Left as Alt-f/Alt-b.
-- Map both encodings explicitly so the leading Escape is not consumed by the
-- Normal-mode <Esc> mapping above.
vim.keymap.set('n', '<M-f>', 'w', { desc = 'Move one word right' })
vim.keymap.set('n', '<M-b>', 'b', { desc = 'Move one word left' })
vim.keymap.set('i', '<M-f>', '<C-o>w', { desc = 'Move one word right' })
vim.keymap.set('i', '<M-b>', '<C-o>b', { desc = 'Move one word left' })

vim.keymap.set('n', '<M-Right>', 'w', { desc = 'Move one word right' })
vim.keymap.set('n', '<M-Left>', 'b', { desc = 'Move one word left' })
vim.keymap.set('i', '<M-Right>', '<C-o>w', { desc = 'Move one word right' })
vim.keymap.set('i', '<M-Left>', '<C-o>b', { desc = 'Move one word left' })

-- Formatting
vim.keymap.set('n', '<leader>p', function()
    local out = vim.fn.system("npx prettier --stdin-filepath " .. vim.fn.expand("%"), vim.fn.getline(1, "$"))
    if vim.v.shell_error ~= 0 then
        vim.notify(out, vim.log.levels.ERROR)
        return
    end
    local view = vim.fn.winsaveview()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(out, "\n", { trimempty = true }))
    vim.fn.winrestview(view)
end, { desc = 'Format buffer with Prettier' })

-- Wrapping
vim.keymap.set('n', '<leader>tw', function()
    vim.wo.wrap = not vim.wo.wrap
    vim.wo.linebreak = vim.wo.wrap
end, { desc = 'Toggle wrap' })

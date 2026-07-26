return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "mason-org/mason.nvim",
        "mason-org/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
        require("mason").setup()
        require("mason-lspconfig").setup()
        require("mason-tool-installer").setup({
            ensure_installed = { "lua_ls", "ts_ls", "eslint_d" }
        })

        vim.lsp.config('*', {
            root_markers = { '.git' },
        })

        vim.diagnostic.config({
            virtual_text  = true,
            severity_sort = true,
            float         = {
                style  = 'minimal',
                border = 'rounded',
                source = 'if_many',
                header = '',
                prefix = '',
            },
            signs         = {
                text = {
                    [vim.diagnostic.severity.ERROR] = '✘',
                    [vim.diagnostic.severity.WARN]  = '▲',
                    [vim.diagnostic.severity.HINT]  = '⚑',
                    [vim.diagnostic.severity.INFO]  = '»',
                },
            },
        })

        local orig = vim.lsp.util.open_floating_preview
        ---@diagnostic disable-next-line: duplicate-set-field
        function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
            opts            = opts or {}
            opts.border     = opts.border or 'rounded'
            opts.max_width  = opts.max_width or 80
            opts.max_height = opts.max_height or 24
            opts.wrap       = opts.wrap ~= false
            return orig(contents, syntax, opts, ...)
        end

        local lsp_group = vim.api.nvim_create_augroup('my.lsp', { clear = true })
        local highlight_group = vim.api.nvim_create_augroup('my.lsp.highlight', { clear = true })
        local format_group = vim.api.nvim_create_augroup('my.lsp.format', { clear = true })

        vim.api.nvim_create_autocmd('LspAttach', {
            group = lsp_group,

            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if not client then
                    return
                end

                local buf = args.buf

                local function map(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, {
                        buffer = buf,
                        silent = true,
                        desc = desc,
                    })
                end

                -- LSP keymaps
                map('n', 'K', vim.lsp.buf.hover, 'LSP: Hover documentation')
                map('n', 'gd', vim.lsp.buf.definition, 'LSP: Go to definition')
                map('n', 'gD', vim.lsp.buf.declaration, 'LSP: Go to declaration')
                map('n', 'gi', vim.lsp.buf.implementation, 'LSP: Go to implementation')
                map('n', 'go', vim.lsp.buf.type_definition, 'LSP: Go to type definition')
                map('n', 'gr', vim.lsp.buf.references, 'LSP: Show references')
                map('n', 'gs', vim.lsp.buf.signature_help, 'LSP: Signature help')
                map('n', 'gl', vim.diagnostic.open_float, 'LSP: Show diagnostic')
                map('n', '<F2>', vim.lsp.buf.rename, 'LSP: Rename symbol')

                map({ 'n', 'x' }, '<F3>', function()
                    vim.lsp.buf.format({
                        bufnr = buf,
                        async = true,
                    })
                end, 'LSP: Format')

                map('n', '<F4>', vim.lsp.buf.code_action, 'LSP: Code action')

                -- Highlight references to the symbol under the cursor.
                if client:supports_method('textDocument/documentHighlight') then
                    -- Remove old autocmds for this buffer before recreating them.
                    vim.api.nvim_clear_autocmds({
                        group = highlight_group,
                        buffer = buf,
                    })

                    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                        group = highlight_group,
                        buffer = buf,
                        callback = vim.lsp.buf.document_highlight,
                        desc = 'Highlight references under cursor',
                    })

                    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                        group = highlight_group,
                        buffer = buf,
                        callback = vim.lsp.buf.clear_references,
                        desc = 'Clear LSP reference highlights',
                    })

                    vim.api.nvim_create_autocmd('LspDetach', {
                        group = highlight_group,
                        buffer = buf,
                        once = true,
                        callback = function()
                            vim.lsp.buf.clear_references()
                        end,
                        desc = 'Clear references when LSP detaches',
                    })
                end

                -- Filetypes where another formatter should be used.
                local excluded_filetypes = {
                    php = true,
                    c = true,
                    cpp = true,
                }

                local filetype = vim.bo[buf].filetype

                local can_format =
                    client:supports_method('textDocument/formatting')
                    and not client:supports_method('textDocument/willSaveWaitUntil')
                    and not excluded_filetypes[filetype]

                if can_format then
                    -- Ensure there is only one format-on-save autocmd per buffer.
                    vim.api.nvim_clear_autocmds({
                        group = format_group,
                        buffer = buf,
                    })

                    vim.api.nvim_create_autocmd('BufWritePre', {
                        group = format_group,
                        buffer = buf,
                        callback = function()
                            -- The client may have detached since the autocmd was created.
                            local current_client = vim.lsp.get_client_by_id(client.id)

                            if not current_client or not current_client.attached_buffers[buf] then
                                return
                            end

                            vim.lsp.buf.format({
                                bufnr = buf,
                                id = client.id,
                                async = false,
                                timeout_ms = 1000,
                            })
                        end,
                        desc = 'Format with LSP before saving',
                    })
                end
            end,
        })

        vim.lsp.config("lua_ls", {
            filetypes = { 'lua' },
            root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
            settings = {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    diagnostics = { globals = { "vim" } },
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            vim.env.VIMRUNTIME,
                            vim.api.nvim_get_runtime_file("lua/lspconfig", false)[1],
                        }
                    },
                    telemetry = { enable = false },
                }
            }
        })
    end
}

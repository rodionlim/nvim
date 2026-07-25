local filetypes = { 'go', 'javascript', 'lua', 'markdown', 'python', 'typescript', 'yaml' }

return {
    {
      'nvim-treesitter/nvim-treesitter',
      lazy = false,
      build = ':TSUpdate',
      config = function()
          require('nvim-treesitter').install(filetypes)
          vim.api.nvim_create_autocmd('FileType', {
              pattern = filetypes,
              callback = function(args)
                  vim.treesitter.start(args.buf)
                  vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                  vim.wo[0][0].foldmethod = 'expr'
                  vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                  vim.wo[0][0].foldlevel = 99
              end,
          })
      end
    }
}

-- Vue 3 / Volar LSP support
-- Uses system-installed vue-language-server and typescript-language-server
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "vue",
        "html",
        "css",
        "scss",
        "javascript",
        "typescript",
        "tsx",
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        volar = {
          filetypes = { "vue" },
          init_options = {
            typescript = {
              -- Try to find typescript lib from npm global or mason
              tsdk = (function()
                local global_ts = vim.fn.trim(vim.fn.system("npm root -g 2>/dev/null"))
                  .. "/typescript/lib"
                if vim.fn.isdirectory(global_ts) == 1 then
                  return global_ts
                end
                local mason_ts = vim.fn.stdpath("data")
                  .. "/mason/packages/typescript-language-server/node_modules/typescript/lib"
                if vim.fn.isdirectory(mason_ts) == 1 then
                  return mason_ts
                end
                return nil
              end)(),
            },
          },
        },
      },
    },
  },
}

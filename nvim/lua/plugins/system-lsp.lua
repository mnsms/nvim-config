-- Enable system-installed LSP servers via vim.lsp.enable()
-- Works on Neovim 0.11+. Servers must be in $PATH.
return {
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = function(_, opts)
      local servers = {
        "clangd",   -- C/C++
        "pyright",  -- Python type checking
        "ruff",     -- Python linting/formating (ruff >= 0.8.0)
        "ts_ls",    -- TypeScript/JavaScript
        "volar",    -- Vue 3 (Volar)
        "jsonls",   -- JSON
        "yamlls",   -- YAML
        "taplo",    -- TOML
        "marksman", -- Markdown
        "bashls",   -- Bash
        "lua_ls",   -- Lua
      }

      for _, server in ipairs(servers) do
        pcall(vim.lsp.enable, server)
      end

      opts.servers = opts.servers or {}
    end,
  },
}

-- Disable Mason auto-install — LSP servers are system-installed
return {
  {
    "mason-org/mason.nvim",
    opts = {
      auto_install = false,
      ensure_installed = {},
      ui = { border = "rounded" },
    },
    -- Override LazyVim's config to skip mason registry refresh/install cycle
    config = function(_, opts)
      require("mason").setup(opts)
    end,
  },
}

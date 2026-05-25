-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  -- Use mirror if in China (detected by proxy or env)
  if vim.env.HTTP_PROXY or vim.env.ALL_PROXY or vim.env.http_proxy then
    lazyrepo = "https://ghfast.top/https://github.com/folke/lazy.nvim.git"
  end
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Detect platform
local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local is_wsl = not is_windows and vim.fn.readfile("/proc/version")[1]:find("WSL") ~= nil
local is_kylin = not is_windows and not is_wsl
  and vim.fn.isdirectory("/etc/kylin") == 1
  or vim.fn.readfile("/etc/os-release", "", 1)[1]:find("Kylin") ~= nil

vim.g.platform = {
  windows = is_windows,
  wsl = is_wsl,
  linux = not is_windows,
  kylin = is_kylin,
}

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = false, -- disable update checker — manual :Lazy update
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

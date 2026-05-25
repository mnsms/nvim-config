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
local is_wsl = false
local is_kylin = false

if not is_windows then
  local proc_version = vim.fn.readfile("/proc/version", "", 1)
  if proc_version[1] and proc_version[1]:find("WSL") then
    is_wsl = true
  elseif vim.fn.isdirectory("/etc/kylin") == 1 or vim.fn.filereadable("/etc/kylin-release") == 1 then
    is_kylin = true
  elseif proc_version[1] and proc_version[1]:find("Kylin") then
    is_kylin = true
  end
end

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

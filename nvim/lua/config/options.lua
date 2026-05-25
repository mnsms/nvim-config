local opt = vim.opt

-- Line numbers
opt.relativenumber = true
opt.number = true

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Clipboard: use system clipboard
-- Windows has native clipboard support
-- Linux needs xclip (Wayland: wl-clipboard)
if vim.g.platform.windows then
  opt.clipboard = "unnamedplus"
elseif vim.fn.executable("xclip") == 1 or vim.fn.executable("wl-copy") == 1 then
  opt.clipboard = "unnamedplus"
end
-- 麒麟V10: if xclip not installed, skip clipboard (use vim register only)

-- Split behavior: new split goes to right/bottom
opt.splitright = true
opt.splitbelow = true

-- Scrolloff: keep context when scrolling
opt.scrolloff = 8
opt.sidescrolloff = 8

-- File encoding
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- Highlight current line
opt.cursorline = true

-- Sign column (always show to prevent layout shift)
opt.signcolumn = "yes"

-- Timeout for mapped sequences
opt.timeoutlen = 300

-- Undo persistence
opt.undofile = true

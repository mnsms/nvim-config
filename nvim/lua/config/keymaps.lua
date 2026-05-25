-- Custom keymaps
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Window navigation (Alt + hjkl)
map("n", "<A-h>", "<C-w>h", opts)
map("n", "<A-j>", "<C-w>j", opts)
map("n", "<A-k>", "<C-w>k", opts)
map("n", "<A-l>", "<C-w>l", opts)

-- Resize splits (Ctrl + Arrow)
map("n", "<C-Up>", ":resize -2<CR>", opts)
map("n", "<C-Down>", ":resize +2<CR>", opts)
map("n", "<C-Left>", ":vertical resize -2<CR>", opts)
map("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Buffers
map("n", "<S-h>", ":bprevious<CR>", opts)
map("n", "<S-l>", ":bnext<CR>", opts)

-- Clear search highlight
map("n", "<leader>ss", ":nohlsearch<CR>", { noremap = true, silent = true, desc = "Clear search highlight" })

-- Quick save
map("n", "<C-s>", ":w<CR>", opts)
map("i", "<C-s>", "<Esc>:w<CR>a", opts)

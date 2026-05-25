# Neovim Config

LazyVim + system-installed LSP servers. Cross-platform for WSL / Ubuntu / 麒麟V10 / Windows.

## Quick Deploy

```bash
# Clone and deploy
git clone https://github.com/mnsms/nvim-config.git ~/projects/nvim-config
~/projects/nvim-config/deploy.sh
```

## Supported Languages

| Language | LSP Server | Formatter |
|----------|-----------|-----------|
| C/C++ | clangd | clang-format |
| Python | pyright + ruff | ruff / black + isort |
| Vue 3 | volar | prettier |
| TypeScript/JS | ts_ls | prettier |
| JSON | jsonls | prettier |
| YAML | yamlls | prettier |
| TOML | taplo | — |
| Markdown | marksman | prettier |
| Lua | lua_ls | stylua |
| Bash | bashls | shfmt |

## Architecture

```
nvim-config/
├── deploy.sh              # One-command deploy (auto-detects platform)
├── nvim/                  # ~/.config/nvim/
│   ├── init.lua
│   └── lua/
│       ├── config/
│       │   ├── lazy.lua   # Bootstrap lazy.nvim + platform detection
│       │   ├── options.lua
│       │   ├── keymaps.lua
│       │   └── autocmds.lua
│       └── plugins/
│           ├── languages.lua    # LazyVim extras (C++/Python/Vue/...)
│           ├── no-mason.lua     # Disable Mason auto-install
│           ├── system-lsp.lua   # Enable system LSP via vim.lsp.enable()
│           ├── format.lua       # Conform formatters
│           └── vue.lua          # Vue 3 Volar config
```

## Platform Notes

### WSL / Ubuntu (main dev)
- Neovim compiled from source (apt version too old)
- All LSP servers via apt + pip + npm
- `deploy.sh` handles everything

### 麒麟V10 (VM, embedded dev)
- Limited package repos, prefers AppImage or source compile
- Some npm packages may need manual install
- Config same as WSL — just works

### Windows (via WSL)
- Run inside WSL, not native Windows
- Config shared via symlink

## Key Decisions

- **System LSP over Mason**: Mason requires downloading from GitHub registry (slow on China servers). System packages install once, work offline.
- **No Mason auto-install**: `no-mason.lua` overrides LazyVim's default to prevent slow network hangs.
- **Platform detection**: `lazy.lua` detects WSL/Kylin/Windows and adjusts behavior (clipboard, mirror URLs).
- **Mirror support**: If `HTTP_PROXY`/`ALL_PROXY` env is set, uses `ghfast.top` GitHub mirror for lazy.nvim bootstrap.

## Keymaps

| Action | Key |
|--------|-----|
| Leader | `Space` |
| File explorer | `Space + e` |
| Find files | `Space + f f` |
| Grep | `Space + s g` |
| Window nav | `Alt + h/j/k/l` |
| Resize | `Ctrl + Arrow` |
| Buffer nav | `Shift + h/l` |
| Save | `Ctrl + s` |
| LSP actions | `Space + c` prefix |

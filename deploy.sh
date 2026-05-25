#!/usr/bin/env bash
# Deploy nvim config across platforms
# Usage: curl -sL https://raw.githubusercontent.com/mnsms/nvim-config/main/deploy.sh | bash
# Or: git clone https://github.com/mnsms/nvim-config.git ~/projects/nvim-config && ~/projects/nvim-config/deploy.sh

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
NVIM_SRC="$REPO_DIR/nvim"
NVIM_DEST="$HOME/.config/nvim"

info()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
ok()    { echo -e "\033[1;32m[OK]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $*"; }
err()   { echo -e "\033[1;31m[ERROR]\033[0m $*"; }

detect_os() {
  if [[ "$(uname -r)" == *"WSL"* ]]; then
    echo "wsl"
  elif [[ -f /etc/kylin-release ]] || grep -qi kylin /etc/os-release 2>/dev/null; then
    echo "kylin"
  elif [[ "$(uname)" == "Linux" ]]; then
    echo "linux"
  elif [[ "$(uname)" == "Darwin" ]]; then
    echo "macos"
  else
    echo "unknown"
  fi
}

check_nvim_version() {
  if command -v nvim &>/dev/null; then
    nvim --version 2>/dev/null | head -1 | grep -oP 'v\d+\.\d+\.\d+'
  else
    echo "none"
  fi
}

# --- Neovim installation ---

install_nvim_linux() {
  local ver
  ver=$(check_nvim_version)
  local major minor
  major=$(echo "$ver" | sed 's/v\([0-9]*\)\..*/\1/')
  minor=$(echo "$ver" | sed 's/v[0-9]*\.\([0-9]*\)\.*/\1/')

  if [[ "$major" == "none" ]] || (( major < 1 && 10#$minor < 11 )); then
    info "Compiling Neovim from source..."
    local tmpdir
    tmpdir=$(mktemp -d)
    local mirror="${MIRROR:-}"

    # Remove apt version if present
    sudo apt-get remove -y neovim 2>/dev/null || true

    sudo apt-get update -qq
    sudo apt-get install -y -qq git cmake ninja-build gettext libtool libtool-bin \
      autoconf automake pkg-config

    # Clone source
    local repo="https://github.com/neovim/neovim.git"
    [[ -n "$mirror" ]] && repo="${mirror}https://github.com/neovim/neovim.git"
    git clone --depth 1 --branch stable "$repo" "$tmpdir/neovim"
    cd "$tmpdir/neovim"
    make CMAKE_BUILD_TYPE=Release -j"$(nproc)"
    sudo make install
    cd /
    rm -rf "$tmpdir"
    ok "Neovim $(nvim --version | head -1) installed to $(which nvim)"
  else
    ok "Neovim $ver already meets requirements"
  fi
}

install_nvim_kylin() {
  local ver
  ver=$(check_nvim_version)
  local major minor
  major=$(echo "$ver" | sed 's/v\([0-9]*\)\..*/\1/')
  minor=$(echo "$ver" | sed 's/v[0-9]*\.\([0-9]*\)\.*/\1/')

  if [[ "$major" == "none" ]] || (( major < 1 && 10#$minor < 11 )); then
    info "Kylin V10 detected. Installing Neovim via AppImage or source..."
    local tmpdir
    tmpdir=$(mktemp -d)

    # Try AppImage first (portable, no compilation)
    local appimg_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
    local mirror="${MIRROR:-}"
    [[ -n "$mirror" ]] && appimg_url="${mirror}${appimg_url}"

    if curl -fsSL --max-time 120 -o "$tmpdir/nvim.appimage" "$appimg_url"; then
      chmod +x "$tmpdir/nvim.appimage"
      sudo mv "$tmpdir/nvim.appimage" /usr/local/bin/nvim
      ok "Neovim AppImage installed"
    else
      warn "AppImage download failed, falling back to source compile..."
      install_nvim_linux "$mirror"
    fi
    rm -rf "$tmpdir"
  else
    ok "Neovim $ver already meets requirements"
  fi
}

# --- System dependencies ---

install_deps_linux() {
  info "Installing system dependencies..."
  sudo apt-get update -qq
  sudo apt-get install -y -qq \
    build-essential cmake ninja-build clangd clang-format \
    ripgrep fd-find xclip curl git \
    python3 python3-pip python3-venv nodejs npm 2>/dev/null || true

  # Python LSP
  pip3 install --user pyright ruff black isort 2>/dev/null || \
    pip3 install --break-system-packages --user pyright ruff black isort 2>/dev/null || true

  # Node.js LSP servers
  npm install -g typescript typescript-language-server vue-language-server \
    prettier vscode-langservers-extracted yaml-language-server 2>/dev/null || true

  # tree-sitter CLI (for treesitter parser compilation)
  if ! command -v tree-sitter &>/dev/null; then
    local mirror="${MIRROR:-}"
    local ts_url="https://github.com/tree-sitter/tree-sitter/releases/download/v0.25.3/tree-sitter-linux-x64.gz"
    [[ -n "$mirror" ]] && ts_url="${mirror}${ts_url}"
    curl -sL "$ts_url" | gunzip > /tmp/tree-sitter && \
      chmod +x /tmp/tree-sitter && sudo mv /tmp/tree-sitter /usr/local/bin/ 2>/dev/null || true
  fi

  ok "Dependencies installed"
}

install_deps_kylin() {
  info "Installing Kylin V10 dependencies..."
  # Kylin uses yum/dnf, limited repos
  sudo yum install -y git gcc gcc-c++ make cmake ninja-build \
    ripgrep fd-find xclip python3 python3-pip nodejs npm curl 2>/dev/null || true

  # Python LSP
  pip3 install --user pyright ruff 2>/dev/null || true

  # Node.js LSP (may need manual node install on Kylin)
  if command -v npm &>/dev/null; then
    npm install -g typescript-language-server vue-language-server \
      prettier vscode-langservers-extracted 2>/dev/null || true
  fi

  warn "Kylin V10: some packages may require manual installation"
}

# --- Config deployment ---

deploy_config() {
  # Backup existing config
  if [[ -d "$NVIM_DEST" && ! -L "$NVIM_DEST" ]]; then
    local backup="$NVIM_DEST.bak.$(date +%Y%m%d%H%M%S)"
    info "Backing up existing config to $backup"
    mv "$NVIM_DEST" "$backup"
  fi

  # Symlink
  ln -sfn "$NVIM_SRC" "$NVIM_DEST"
  ok "Config linked: $NVIM_DEST -> $NVIM_SRC"
}

# --- Main ---

main() {
  echo ""
  echo "========================================"
  echo "  Neovim Config Deploy"
  echo "  Platform: $(detect_os)"
  echo "========================================"
  echo ""

  local os
  os=$(detect_os)

  # Step 1: Install Neovim
  info "Step 1/3: Checking Neovim..."
  case "$os" in
    wsl|linux) install_nvim_linux ;;
    kylin)     install_nvim_kylin ;;
  esac

  # Step 2: Install dependencies
  info "Step 2/3: Installing dependencies..."
  case "$os" in
    wsl|linux) install_deps_linux ;;
    kylin)     install_deps_kylin ;;
  esac

  # Step 3: Deploy config
  info "Step 3/3: Deploying config..."
  deploy_config

  echo ""
  ok "Done! Run 'nvim' to start."
  echo ""
  echo "First run will:"
  echo "  1. Download ~40 plugins (use :Lazy to monitor)"
  echo "  2. Compile treesitter parsers automatically"
  echo "  3. LSP servers activate on file open"
  echo ""
}

main "$@"

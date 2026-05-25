# Deploy script for Windows (PowerShell)
# Usage: pwsh -File deploy.ps1
# Or: .\deploy.ps1

$ErrorActionPreference = "Stop"

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$NvimSrc = Join-Path $RepoDir "nvim"
$NvimDest = "$env:LOCALAPPDATA\nvim"

function Write-Info($msg)  { Write-Host "[INFO] " -ForegroundColor Blue -NoNewline; Write-Host $msg }
function Write-OK($msg)    { Write-Host "[OK] " -ForegroundColor Green -NoNewline; Write-Host $msg }
function Write-Warn($msg)  { Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline; Write-Host $msg }
function Write-Err($msg)   { Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host $msg }

# --- Check scoop/chocolatey ---
function Get-PackageManager() {
    if (Get-Command scoop -ErrorAction SilentlyContinue) { return "scoop" }
    if (Get-Command choco -ErrorAction SilentlyContinue) { return "choco" }
    return $null
}

# --- Install Neovim ---
function Install-Neovim {
    $nvim = Get-Command nvim -ErrorAction SilentlyContinue
    if ($nvim) {
        $ver = & nvim --version 2>$null | Select-Object -First 1
        Write-OK "Neovim already installed: $ver"
        return
    }

    $pm = Get-PackageManager
    if ($pm -eq "scoop") {
        Write-Info "Installing Neovim via scoop..."
        scoop install neovim
    } elseif ($pm -eq "choco") {
        Write-Info "Installing Neovim via chocolatey..."
        choco install neovim -y
    } else {
        # Manual: download release tarball
        Write-Info "No package manager found. Downloading Neovim release..."
        $url = "https://github.com/neovim/neovim/releases/latest/download/nvim-win64.zip"
        $tmpZip = "$env:TEMP\nvim.zip"
        $tmpDir = "$env:TEMP\nvim-install"

        try {
            $ProgressPreference = "SilentlyContinue"
            Invoke-WebRequest -Uri $url -OutFile $tmpZip -UseBasicParsing
            Expand-Archive -Path $tmpZip -DestinationPath $tmpDir -Force
            # Add to PATH (user scope)
            $nvimDir = Join-Path $tmpDir "nvim-win64" "bin"
            $pathDirs = $env:PATH -split ";" | Where-Object { $_ -ne $nvimDir }
            $newPath = ($nvimDir + ";" + ($pathDirs -join ";"))
            [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
            $env:PATH = $newPath
            Write-OK "Neovim installed to $nvimDir (added to user PATH)"
            Write-Warn "Restart your terminal for PATH to take effect"
        } finally {
            Remove-Item $tmpZip -ErrorAction SilentlyContinue
        }
    }
}

# --- Install LSP dependencies ---
function Install-Deps {
    $pm = Get-PackageManager

    # Node.js (required for most LSP servers)
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        if ($pm -eq "scoop") {
            scoop install nodejs-lts
        } elseif ($pm -eq "choco") {
            choco install nodejs-lts -y
        } else {
            Write-Warn "Node.js not found. Install manually from https://nodejs.org"
        }
    }

    # Python3 + pyright/ruff
    if (-not (Get-Command pyright -ErrorAction SilentlyContinue)) {
        pip install pyright ruff black isort 2>$null
    }

    # Node.js LSP servers
    $npmPkgs = @(
        "typescript",
        "typescript-language-server",
        "vue-language-server",
        "prettier",
        "vscode-langservers-extracted",
        "yaml-language-server"
    )
    foreach ($pkg in $npmPkgs) {
        if (npm list -g $pkg 2>$null | Select-String $pkg) {
            Write-Info "$pkg already installed"
        } else {
            npm install -g $pkg 2>$null
        }
    }

    # ripgrep + fd (for telescope)
    if (-not (Get-Command rg -ErrorAction SilentlyContinue)) {
        if ($pm -eq "scoop") { scoop install ripgrep fd }
        elseif ($pm -eq "choco") { choco install ripgrep fd -y }
    }

    # tree-sitter CLI
    if (-not (Get-Command tree-sitter -ErrorAction SilentlyContinue)) {
        if ($pm -eq "scoop") { scoop install tree-sitter }
        elseif ($pm -eq "choco") { choco install tree-sitter -y }
    }

    Write-OK "Dependencies installed"
}

# --- Deploy config ---
function Deploy-Config {
    if (Test-Path $NvimDest -PathType Container) {
        if (-not (Test-Path $NvimDest -PathType Container)) {
            # Symlink or junction - check
            $item = Get-Item $NvimDest -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                # Already a symlink, remove it
                Remove-Item $NvimDest -Force
            } else {
                # Backup
                $backup = "$NvimDest.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
                Write-Info "Backing up to $backup"
                Rename-Item $NvimDest $backup
            }
        }
    }

    # Create junction (works without admin, unlike symlinks on Windows)
    cmd /c mklink /J "$NvimDest" "$NvimSrc" | Out-Null
    Write-OK "Config linked: $NvimDest -> $NvimSrc"
}

# --- Main ---
Write-Host ""
Write-Host "========================================"
Write-Host "  Neovim Config Deploy (Windows)"
Write-Host "========================================"
Write-Host ""

Write-Info "Step 1/3: Checking Neovim..."
Install-Neovim

Write-Info "Step 2/3: Installing dependencies..."
Install-Deps

Write-Info "Step 3/3: Deploying config..."
Deploy-Config

Write-Host ""
Write-OK "Done! Open a new terminal and run 'nvim'"
Write-Host ""

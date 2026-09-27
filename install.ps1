# PowerShell installer for jev-superpowers
$ErrorActionPreference = "Stop"

Write-Host "⚡ Installing jev-superpowers..." -ForegroundColor Cyan

$targetDir = Join-Path $HOME ".agents\skills"
if (!(Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Copy skills
Get-ChildItem (Join-Path $scriptDir "skills") | ForEach-Object {
    $dest = Join-Path $targetDir $_.Name
    Copy-Item $_.FullName -Destination $dest -Recurse -Force
}

Write-Host "✔ Skills installed to $targetDir" -ForegroundColor Green

# Check tooling
Write-Host "`n🔍 Checking TypeSafe Jev tooling on PATH..." -ForegroundColor Cyan

$missing = 0

function Check-Tool ($tool, $installCmd) {
    $cmd = Get-Command $tool -ErrorAction SilentlyContinue
    if ($cmd) {
        Write-Host "  ✔ $tool found ($($cmd.Source))" -ForegroundColor Green
    } else {
        Write-Host "  ✘ $tool MISSING! Install via: $installCmd" -ForegroundColor Red
        $script:missing++
    }
}

function Check-GitSubcommand ($name, $installCmd) {
    git $name --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✔ git $name found" -ForegroundColor Green
    } else {
        Write-Host "  ✘ git $name MISSING! Install via: $installCmd" -ForegroundColor Red
        $script:missing++
    }
}

Check-Tool "jev-scout" "cargo install jev-scout"
Check-Tool "jev-axi" "npm install -g jev-axi"
Check-GitSubcommand "jev" "git jev install"
Check-Tool "jev-guard" "npm install -g jev-guard"
Check-Tool "supercov" "npm install -g supercov"
$limpetInstalled = (Test-Path "$HOME\limpet\limpet.py") -or (Get-Command limpet -ErrorAction SilentlyContinue)
if ($limpetInstalled) {
    Write-Host "  ✔ limpet found" -ForegroundColor Green
} else {
    Write-Host "  ✘ limpet MISSING! Install via: git clone https://github.com/noplan-inc/limpet `$HOME\limpet" -ForegroundColor Red
    $missing++
}
Check-Tool "jev-seo" "cargo install jev-seo"

$hasLocal = [bool]($env:TYPESAFE_BASE_URL -or ($env:TYPESAFE_BACKEND -eq "laya"))

# Provider selection: JEV_PROVIDER=openjev wins; else TypeSafe if TYPESAFE_API_KEY set; else OpenJEV if OPENJEV_API_KEY set
$useOpenJEV = $false
if ($env:JEV_PROVIDER -eq "openjev") {
    $useOpenJEV = $true
} elseif (!$env:TYPESAFE_API_KEY -and $env:OPENJEV_API_KEY) {
    $useOpenJEV = $true
}

if ($useOpenJEV -and !$hasLocal) {
    if ($env:OPENJEV_API_KEY) {
        Write-Host "`n✔ OPENJEV_API_KEY is configured (OpenJEV gateway to Jev)." -ForegroundColor Green
    } else {
        Write-Host "`n❌ JEV_PROVIDER=openjev but OPENJEV_API_KEY is not set." -ForegroundColor Red
        Write-Host "  Get your free API key at https://openjev.sh/dashboard" -ForegroundColor Red
        exit 1
    }
} elseif (!$env:TYPESAFE_API_KEY -and !$hasLocal) {
    Write-Host "`n❌ Neither TYPESAFE_API_KEY nor OPENJEV_API_KEY nor local FOSS backend is configured." -ForegroundColor Red
    Write-Host "  TypeSafe Cloud: Get your free API key at https://console.typesafe.ai"
    Write-Host "  OpenJEV Gateway: Get your free API key at https://openjev.sh/dashboard"
    Write-Host "  Local FOSS: Run Laya via 'python scripts/serve-laya.py' and set:"
    Write-Host "    `$env:TYPESAFE_BASE_URL = 'http://127.0.0.1:8000'"
    Write-Host "    `$env:TYPESAFE_API_KEY = 'local'"
    $missing++
} elseif ($hasLocal) {
    Write-Host "`n✔ Local FOSS System 1 backend configured ($($env:TYPESAFE_BASE_URL) / Laya)." -ForegroundColor Green
    if (!$env:TYPESAFE_API_KEY) {
        $env:TYPESAFE_API_KEY = "local"
    }
} else {
    Write-Host "`n✔ TYPESAFE_API_KEY is configured." -ForegroundColor Green
}

if ($missing -gt 0) {
    Write-Host "`n⚠️  Skills installed successfully, but $missing prerequisite tool(s) were not detected." -ForegroundColor Yellow
    Write-Host "   Install the missing tools above to activate their respective Jev reflex gates." -ForegroundColor Yellow
} else {
    Write-Host "`n✔ All TypeSafe Jev tools and environment variables verified!" -ForegroundColor Green
}

Write-Host "`n🚀 jev-superpowers ready! Use 'jev-using-superpowers' or 'jev-brainstorming' in your agent sessions." -ForegroundColor Cyan

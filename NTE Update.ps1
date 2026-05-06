$owner = "CallMeDangDev"
$repo = "NTE-Viet-Hoa"

$api = "https://api.github.com/repos/$owner/$repo/releases/latest"

# keyword để search app
$appKeyword = "Neverness To Everness"

# 4 file cần download
$targetFiles = @(
    "netbios.dll",
    "game_vi.dat",
    "viet_font.ttf"
)

# =========================
# 🔍 FIND INSTALL PATH
# =========================
function Find-InstallPath {
    param ([string]$keyword)

    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($path in $paths) {
        $result = Get-ItemProperty $path -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "*$keyword*" -and $_.InstallLocation } |
            Select-Object -First 1

        if ($result) {
            Write-Host "Matched app:" $result.DisplayName
            return $result.InstallLocation
        }
    }

    return $null
}

# =========================
# 🔍 GET INSTALL PATH
# =========================
$installPath = Find-InstallPath $appKeyword

if (-not $installPath) {
    Write-Host "❌ Không tìm thấy app"
    $installPath = Read-Host "Nhập đường dẫn root game"
}

if (-not (Test-Path $installPath)) {
    Write-Host "❌ Path không tồn tại!"
    Read-Host "Nhấn Enter để thoát..."
    exit
}

Write-Host "📂 Root path: $installPath"

# =========================
# 🔥 AUTO DETECT WIN64 FOLDER (BEST)
# =========================
Write-Host "🔍 Searching Win64 folder..."

$targetPath = Get-ChildItem $installPath -Recurse -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like "*\Client\WindowsNoEditor\HT\Binaries\Win64" } |
    Select-Object -First 1 -ExpandProperty FullName

if (-not $targetPath) {
    Write-Host "❌ Không auto detect được folder Win64"
    $targetPath = Read-Host "Nhập path Win64"
}

# =========================
# 🔐 VALIDATE FOLDER
# =========================
if (-not (Test-Path $targetPath)) {
    Write-Host "❌ Target path không tồn tại!"
    Read-Host "Nhấn Enter để thoát..."
    exit
}

# check có exe (dấu hiệu folder game đúng)
$exeFile = Get-ChildItem $targetPath -Filter "*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $exeFile) {
    Write-Host "❌ Không tìm thấy file .exe → có thể sai folder"
    Write-Host "📂 Target: $targetPath"
    Read-Host "Nhấn Enter để thoát..."
    exit
}

Write-Host "📂 Target path: $targetPath"
Write-Host "🎮 Detected exe: $($exeFile.Name)"

# =========================
# 🔄 CHECK VERSION
# =========================
Write-Host "Checking latest version..."

$response = Invoke-RestMethod -Uri $api
$latestVersion = $response.tag_name
$versionFile = Join-Path $targetPath ".latest_version"

# check mod tồn tại chưa
$modExists = $true
foreach ($file in $targetFiles) {
    $fullPath = Join-Path $targetPath $file
    if (-not (Test-Path $fullPath)) {
        $modExists = $false
        break
    }
}

# đọc version từ folder game
if (Test-Path $versionFile) {
    $currentVersion = Get-Content $versionFile
} else {
    $currentVersion = ""
}

Write-Host "Latest: $latestVersion"
Write-Host "Current: $currentVersion"
Write-Host "Mod installed: $modExists"

# logic chuẩn
if ($modExists -and $latestVersion -eq $currentVersion) {
    Write-Host "No new version. Skip download."
    Read-Host "Nhấn Enter để thoát..."
    exit
}

if (-not $modExists) {
    Write-Host "⚠️ Mod chưa được cài → sẽ download"
}

# =========================
# ✅ STRICT CHECK FILE
# =========================
$foundFiles = @()

foreach ($asset in $response.assets) {
    if ($targetFiles -contains $asset.name) {
        $foundFiles += $asset.name
    }
}

if ($foundFiles.Count -ne $targetFiles.Count) {
    Write-Host "❌ ERROR: Missing required files!"
    Write-Host "Expected: $($targetFiles -join ', ')"
    Write-Host "Found: $($foundFiles -join ', ')"
    Read-Host "Nhấn Enter để thoát..."
    exit
}

# =========================
# 🧹 DELETE OLD FILES
# =========================
Write-Host "Cleaning old files..."

foreach ($file in $targetFiles) {
    $fullPath = Join-Path $targetPath $file

    if (Test-Path $fullPath) {
        Remove-Item $fullPath -Force
        Write-Host "Deleted: $fullPath"
    }
}

# =========================
# ⬇️ DOWNLOAD FILES
# =========================
Write-Host "Downloading new files..."

foreach ($asset in $response.assets) {
    if ($targetFiles -contains $asset.name) {
        $name = $asset.name
        $url = $asset.browser_download_url
        $fullPath = Join-Path $targetPath $name

        Write-Host "Downloading: $fullPath"
        Invoke-WebRequest -Uri $url -OutFile $fullPath
    }
}

# =========================
# 💾 SAVE VERSION
# =========================
$latestVersion | Out-File $versionFile -Encoding utf8

Write-Host "✅ Done! Updated to version $latestVersion"

for ($i = 5; $i -gt 0; $i--) {
    Write-Host "⏳ Closing in $i..."
    Start-Sleep -Seconds 1
}
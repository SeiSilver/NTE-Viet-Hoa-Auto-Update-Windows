$owner = "CallMeDangDev"
$repo = "NTE-Viet-Hoa"

$api = "https://api.github.com/repos/$owner/$repo/releases/latest"

# keyword Ä‘á»ƒ search app
$appKeyword = "Neverness To Everness"

# 4 file cáº§n download
$targetFiles = @(
    "netbios.dll",
    "game_vi.dat",
    "viet_font.ttf"
)

# =========================
# ðŸ” FIND INSTALL PATH
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
# ðŸ” GET INSTALL PATH
# =========================
$installPath = Find-InstallPath $appKeyword

if (-not $installPath) {
    Write-Host "âŒ KhÃ´ng tÃ¬m tháº¥y app"
    $installPath = Read-Host "Nháº­p Ä‘Æ°á»ng dáº«n root game"
}

if (-not (Test-Path $installPath)) {
    Write-Host "âŒ Path khÃ´ng tá»“n táº¡i!"
    Read-Host "Nháº¥n Enter Ä‘á»ƒ thoÃ¡t..."
    exit
}

Write-Host "ðŸ“‚ Root path: $installPath"

# =========================
# ðŸ”¥ AUTO DETECT WIN64 FOLDER (BEST)
# =========================
Write-Host "ðŸ” Searching Win64 folder..."

$targetPath = Get-ChildItem $installPath -Recurse -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like "*\Client\WindowsNoEditor\HT\Binaries\Win64" } |
    Select-Object -First 1 -ExpandProperty FullName

if (-not $targetPath) {
    Write-Host "âŒ KhÃ´ng auto detect Ä‘Æ°á»£c folder Win64"
    $targetPath = Read-Host "Nháº­p path Win64"
}

# =========================
# ðŸ” VALIDATE FOLDER
# =========================
if (-not (Test-Path $targetPath)) {
    Write-Host "âŒ Target path khÃ´ng tá»“n táº¡i!"
    Read-Host "Nháº¥n Enter Ä‘á»ƒ thoÃ¡t..."
    exit
}

# check cÃ³ exe (dáº¥u hiá»‡u folder game Ä‘Ãºng)
$exeFile = Get-ChildItem $targetPath -Filter "*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $exeFile) {
    Write-Host "âŒ KhÃ´ng tÃ¬m tháº¥y file .exe â†’ cÃ³ thá»ƒ sai folder"
    Write-Host "ðŸ“‚ Target: $targetPath"
    Read-Host "Nháº¥n Enter Ä‘á»ƒ thoÃ¡t..."
    exit
}

Write-Host "ðŸ“‚ Target path: $targetPath"
Write-Host "ðŸŽ® Detected exe: $($exeFile.Name)"

# =========================
# ðŸ”„ CHECK VERSION
# =========================
Write-Host "Checking latest version..."

$response = Invoke-RestMethod -Uri $api
$latestVersion = $response.tag_name
$versionFile = Join-Path $targetPath ".latest_version"

# check mod tá»“n táº¡i chÆ°a
$modExists = $true
foreach ($file in $targetFiles) {
    $fullPath = Join-Path $targetPath $file
    if (-not (Test-Path $fullPath)) {
        $modExists = $false
        break
    }
}

# Ä‘á»c version tá»« folder game
if (Test-Path $versionFile) {
    $currentVersion = Get-Content $versionFile
} else {
    $currentVersion = ""
}

Write-Host "Latest: $latestVersion"
Write-Host "Current: $currentVersion"
Write-Host "Mod installed: $modExists"

# logic chuáº©n
if ($modExists -and $latestVersion -eq $currentVersion) {
    Write-Host "No new version. Skip download."
    Read-Host "Nháº¥n Enter Ä‘á»ƒ thoÃ¡t..."
    exit
}

if (-not $modExists) {
    Write-Host "âš ï¸ Mod chÆ°a Ä‘Æ°á»£c cÃ i â†’ sáº½ download"
}

# =========================
# âœ… STRICT CHECK FILE
# =========================
$foundFiles = @()

foreach ($asset in $response.assets) {
    if ($targetFiles -contains $asset.name) {
        $foundFiles += $asset.name
    }
}

if ($foundFiles.Count -ne $targetFiles.Count) {
    Write-Host "âŒ ERROR: Missing required files!"
    Write-Host "Expected: $($targetFiles -join ', ')"
    Write-Host "Found: $($foundFiles -join ', ')"
    Read-Host "Nháº¥n Enter Ä‘á»ƒ thoÃ¡t..."
    exit
}

# =========================
# ðŸ§¹ DELETE OLD FILES
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
# â¬‡ï¸ DOWNLOAD FILES
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
# ðŸ’¾ SAVE VERSION
# =========================
$latestVersion | Out-File $versionFile -Encoding utf8

Write-Host "âœ… Done! Updated to version $latestVersion"

for ($i = 5; $i -gt 0; $i--) {
    Write-Host "â³ Closing in $i..."
    Start-Sleep -Seconds 1
}

$owner = "CallMeDangDev"
$repo = "NTE-Viet-Hoa"
$api = "https://api.github.com/repos/$owner/$repo/releases/latest"
Write-Host $api

# keyword to search app
$appKeyword = "Neverness To Everness"

# target files
$targetFiles = @(
    "netbios.dll",
    "game_vi.dat",
    "viet_font.ttf"
)

# =========================
# FIND INSTALL PATH
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
# GET INSTALL PATH
# =========================
$installPath = Find-InstallPath $appKeyword

if (-not $installPath) {
    Write-Host "App not found"
    $installPath = Read-Host "Enter game root path"
}

if (-not (Test-Path $installPath)) {
    Write-Host "Path does not exist"
    Read-Host "Press Enter to exit..."
    exit
}

Write-Host "Root path: $installPath"

# =========================
# AUTO DETECT WIN64
# =========================
Write-Host "Searching Win64 folder..."

$targetPath = Get-ChildItem $installPath -Recurse -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like "*\Client\WindowsNoEditor\HT\Binaries\Win64" } |
    Select-Object -First 1 -ExpandProperty FullName

if (-not $targetPath) {
    Write-Host "Cannot auto detect Win64 folder"
    $targetPath = Read-Host "Enter Win64 path"
}

# =========================
# VALIDATE FOLDER
# =========================
if (-not (Test-Path $targetPath)) {
    Write-Host "Target path does not exist"
    Read-Host "Press Enter to exit..."
    exit
}

$exeFile = Get-ChildItem $targetPath -Filter "HTGame.exe" -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $exeFile) {
    Write-Host "No .exe found. Wrong folder?"
    Write-Host "Target: $targetPath"
    Read-Host "Press Enter to exit..."
    exit
}

Write-Host "Target path: $targetPath"
Write-Host "Detected exe: $($exeFile.Name)"

# =========================
# CHECK VERSION
# =========================
Write-Host "Checking latest version..."

$response = Invoke-RestMethod -Uri $api
$latestVersion = $response.tag_name
$versionFile = Join-Path $targetPath ".latest_version"

# check if mod exists
$modExists = $true
foreach ($file in $targetFiles) {
    $fullPath = Join-Path $targetPath $file
    if (-not (Test-Path $fullPath)) {
        $modExists = $false
        break
    }
}

# read version
if (Test-Path $versionFile) {
    $currentVersion = Get-Content $versionFile
} else {
    $currentVersion = ""
}

Write-Host "Latest: $latestVersion"
Write-Host "Current: $currentVersion"
Write-Host "Mod installed: $modExists"

if ($modExists -and $latestVersion -eq $currentVersion) {
    Write-Host "No update needed"
    Read-Host "Press Enter to exit..."
    exit
}

if (-not $modExists) {
    Write-Host "Mod not installed. Will download"
}

# =========================
# STRICT CHECK FILE
# =========================
$foundFiles = @()

foreach ($asset in $response.assets) {
    if ($targetFiles -contains $asset.name) {
        $foundFiles += $asset.name
    }
}

if ($foundFiles.Count -ne $targetFiles.Count) {
    Write-Host "ERROR: Missing required files"
    Write-Host "Expected: $($targetFiles -join ', ')"
    Write-Host "Found: $($foundFiles -join ', ')"
    Read-Host "Press Enter to exit..."
    exit
}

# =========================
# DELETE OLD FILES
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
# DOWNLOAD FILES
# =========================
Write-Host "Downloading..."

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
# SAVE VERSION
# =========================
$latestVersion | Out-File $versionFile -Encoding utf8

Write-Host "Done! Updated to version $latestVersion"

Read-Host "Press Enter to exit..."

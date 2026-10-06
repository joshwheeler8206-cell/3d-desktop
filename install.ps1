# 3D Desktop Themes - installer (OPTIONAL)
# Creates a Desktop + Start Menu shortcut for each theme, running
# borderless full-screen in Edge or Chrome from the local disk.
#
# You do NOT need this.  The two .html files next to this installer are
# self-contained and work by double-clicking.  Use this only if you want
# icons you can click every day without finding the file again.
#
# Installs to %LOCALAPPDATA%\3D-Desktop.  No administrator rights needed.

$ErrorActionPreference = 'Stop'
$src    = Split-Path -Parent $MyInvocation.MyCommand.Path
$appDir = Join-Path $env:LOCALAPPDATA '3D-Desktop'

$apps = @(
    @{ file = 'autoforce-3d-desktop.html'
       link = 'AutoForce 3D Desktop.lnk'
       png  = 'autoforce-3d-desktop-1920x1080.png'
       desc = 'U.S. AutoForce 3D desktop (logo + clock)' },
    @{ file = 'usmc-3d-desktop.html'
       link = 'USMC 3D Desktop.lnk'
       png  = 'usmc-3d-desktop-1920x1080.png'
       desc = 'USMC 3D desktop (globe-and-anchor + Semper Fidelis)' }
)

# every folder here is a Lively wallpaper package; add a line to add a theme
$livelyDirNames = @('AutoForce-3D-Lively', 'USMC-3D-Lively')

function Step($m) { Write-Host "  $m" -ForegroundColor DarkGray }
function Ok($m)   { Write-Host "  [ok] $m" -ForegroundColor Green }
function Warn($m) { Write-Host "  [!!] $m" -ForegroundColor Yellow }
function Die($m)  { Write-Host "  [XX] $m" -ForegroundColor Red; exit 1 }

Write-Host ''
Write-Host '  3D Desktop Themes  -  shortcut installer' -ForegroundColor Cyan
Write-Host '  ------------------------------------------------' -ForegroundColor DarkGray
Write-Host ''

# ---------------------------------------------------------------- payload
$missing = @()
foreach ($a in $apps) { if (-not (Test-Path (Join-Path $src $a.file))) { $missing += $a.file } }
if ($missing.Count -gt 0) { Die "Missing next to this installer: $($missing -join ', ')" }
Step "found both themes in $src"
$livelyFound = @()
foreach ($ln in $livelyDirNames) {
    if (Test-Path (Join-Path (Join-Path $src $ln) 'LivelyProperties.json')) {
        $livelyFound += $ln
        Step "found the $ln Lively wallpaper folder"
    } else { Warn "no $ln folder - skipping it" }
}

# ---------------------------------------------------------------- install
New-Item -ItemType Directory -Force -Path $appDir | Out-Null
foreach ($a in $apps) {
    Copy-Item (Join-Path $src $a.file) (Join-Path $appDir $a.file) -Force
    if (Test-Path (Join-Path $src $a.png)) {
        Copy-Item (Join-Path $src $a.png) (Join-Path $appDir $a.png) -Force
    }
    Ok "copied $($a.file)"
}
foreach ($ln in $livelyFound) {
    $dst = Join-Path $appDir $ln
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    Copy-Item (Join-Path (Join-Path $src $ln) '*') $dst -Recurse -Force
    Ok "copied the $ln folder"
}

# ---------------------------------------------------------------- browser
function Find-Browser {
    $cands = @(
        "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
        "${env:ProgramFiles}\Microsoft\Edge\Application\msedge.exe",
        "${env:LocalAppData}\Microsoft\Edge\Application\msedge.exe",
        "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
        "${env:LocalAppData}\Google\Chrome\Application\chrome.exe"
    )
    foreach ($c in $cands) { if ($c -and (Test-Path $c)) { return $c } }
    foreach ($n in 'msedge','chrome') {
        $g = Get-Command $n -ErrorAction SilentlyContinue
        if ($g) { return $g.Source }
    }
    return $null
}
$browser = Find-Browser
if (-not $browser) { Die 'Could not find Microsoft Edge or Google Chrome on this PC.' }
Ok "browser: $(Split-Path -Leaf $browser)"

# ---------------------------------------------------------------- shortcuts
$sh = New-Object -ComObject WScript.Shell
$desktop   = [Environment]::GetFolderPath('Desktop')
$startMenu = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'

function Make-Shortcut($appPath, $linkPath, $desc) {
    # a space in the path must become %20 or Edge refuses the file:/// URL
    $fileUrl = 'file:///' + ($appPath -replace '\\','/') -replace ' ','%20'
    $l = $sh.CreateShortcut($linkPath)
    $l.TargetPath       = $browser
    $l.Arguments        = "--app=`"$fileUrl`" --kiosk --no-first-run --disable-features=Translate"
    $l.WorkingDirectory = $appDir
    $l.Description      = $desc
    $l.WindowStyle      = 1
    $l.Save()
    return $fileUrl
}

$urls = @{}
foreach ($a in $apps) {
    $appHtml = Join-Path $appDir $a.file
    $urls[$a.file] = Make-Shortcut $appHtml (Join-Path $desktop $a.link) $a.desc
    Ok "Desktop shortcut: $($a.link)"
    try { Make-Shortcut $appHtml (Join-Path $startMenu $a.link) $a.desc | Out-Null }
    catch { Warn "Start Menu shortcut failed for $($a.link) (Desktop is fine)" }
}

# ---------------------------------------------------------------- wallpaper
$pick = Read-Host '  Set one of the still images as your desktop wallpaper too? 1 = AutoForce, 2 = USMC, [n] = skip'
if ($pick -match '^[12]') {
    $sel = if ($pick -eq '1') { $apps[0] } else { $apps[1] }
    try {
        $png = Join-Path $appDir $sel.png
        if (-not (Test-Path $png)) { Warn "$($sel.png) not found - wallpaper unchanged" }
        else {
            Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value '10'
            Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper  -Value '0'
            Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper     -Value $png
            $sig = @'
[DllImport("user32.dll", CharSet=CharSet.Unicode)]
public static extern int SystemParametersInfo(int a, int b, string c, int d);
'@
            $t = Add-Type -MemberDefinition $sig -Name TWin32 -Namespace T3D -PassThru
            $t::SystemParametersInfo(20, 0, $png, 3) | Out-Null
            Ok "desktop wallpaper set from $($sel.png)"
        }
    } catch { Warn "could not set wallpaper: $($_.Exception.Message)" }
} else { Step 'wallpaper left unchanged' }

# ---------------------------------------------------------------- done
Write-Host ''
Write-Host '  Installed both themes.' -ForegroundColor Green
Write-Host "  Location : $appDir"
Write-Host ''
Write-Host '  Desktop icons:' -ForegroundColor White
Write-Host '    AutoForce 3D Desktop  - company logo, safety line, live clock'
Write-Host '    USMC 3D Desktop       - globe-and-anchor, Semper Fidelis, clock'
Write-Host ''
Write-Host '  Controls : 1-4 scene | SPACE pause | F fullscreen | ESC close' -ForegroundColor DarkGray
Write-Host ''

if ($livelyFound.Count -gt 0) {
    $livelyExe = $null
    foreach ($c in @("${env:ProgramFiles}\Lively Wallpaper\livelywallpaper.exe",
                     "${env:ProgramFiles(x86)}\Lively Wallpaper\livelywallpaper.exe",
                     "${env:LocalAppData}\Programs\Lively Wallpaper\livelywallpaper.exe")) {
        if ($c -and (Test-Path $c)) { $livelyExe = $c; break }
    }
    Write-Host '  REAL DESKTOP BACKGROUND (behind your icons)' -ForegroundColor Cyan
    Write-Host '    Free app: Microsoft Store > search "Lively Wallpaper".'
    Write-Host '    Then Lively > Library > Add > pick one of these folders:'
    foreach ($ln in $livelyFound) { Write-Host "      $appDir\$ln" }
    if ($livelyExe) {
        Write-Host ''
        Write-Host '    Lively is already installed - shall I open it? [Y/n]'
        $go2 = Read-Host
        if ($go2 -eq '' -or $go2 -match '^[Yy]') {
            try { Start-Process -FilePath $livelyExe; Ok 'Lively started' }
            catch { Warn "could not start Lively: $($_.Exception.Message)" }
        }
    }
    Write-Host ''
}

$go = Read-Host '  Open one now to check it works? 1 = AutoForce, 2 = USMC, [n] = skip'
if ($go -match '^[12]') {
    $sel = if ($go -eq '1') { $apps[0] } else { $apps[1] }
    Start-Process -FilePath $browser `
        -ArgumentList @("--app=`"$($urls[$sel.file])`"", '--kiosk', '--no-first-run')
    Ok "launched $($sel.file)"
}
Write-Host ''
Write-Host '  To remove: run uninstall.bat (or delete the folder above).' -ForegroundColor DarkGray
Write-Host ''
Start-Sleep -Seconds 6

# 3D Desktop Themes - uninstaller.  Removes the installed folder, both Desktop
# shortcuts, both Start Menu shortcuts, and (optionally) resets the wallpaper
# if it currently points at one of our images.

$ErrorActionPreference = 'SilentlyContinue'
$appDir = Join-Path $env:LOCALAPPDATA '3D-Desktop'
$links  = @('AutoForce 3D Desktop.lnk', 'USMC 3D Desktop.lnk')

$desktop   = [Environment]::GetFolderPath('Desktop')
$startMenu = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'

# a shortcut that is still open in a browser is a locked-ish file; say so
$running = @(Get-Process msedge, chrome -ErrorAction SilentlyContinue)
if ($running.Count -gt 0) {
    Write-Host '  [!!] Edge or Chrome is running.' -ForegroundColor Yellow
    Write-Host '       Close any open theme window (press ESC in it) and try again.' -ForegroundColor Yellow
    Write-Host '       Removing the folder anyway will still work.' -ForegroundColor DarkGray
}

$pngs = @('autoforce-3d-desktop-1920x1080.png','usmc-3d-desktop-1920x1080.png')
$cur = (Get-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper).Wallpaper
if ($cur) {
    foreach ($p in $pngs) {
        if ($cur -like (Join-Path $appDir $p)) {
            Write-Host '  [!] desktop wallpaper still points at our image' -ForegroundColor Yellow
            Write-Host '      Windows Settings > Personalisation > Background > change it there.' -ForegroundColor Yellow
        }
    }
}

$fail = 0
foreach ($l in $links) {
    foreach ($dir in @($desktop, $startMenu)) {
        $path = Join-Path $dir $l
        if (Test-Path $path) {
            Remove-Item $path -Force
            if (Test-Path $path) { Write-Host "  [XX] could not delete $l" -ForegroundColor Red; $fail++ }
            else { Write-Host "  [ok] removed $l" -ForegroundColor Green }
        }
    }
}

if (Test-Path $appDir) {
    Remove-Item $appDir -Recurse -Force
    if (Test-Path $appDir) {
        Write-Host "  [XX] could not fully remove $appDir" -ForegroundColor Red
        $fail++
    } else { Write-Host "  [ok] removed $appDir" -ForegroundColor Green }
}

Write-Host ''
if ($fail -gt 0) {
    Write-Host "  Finished with $fail problem(s) - close the browser and retry, or"
    Write-Host "  delete the folder by hand from File Explorer." -ForegroundColor Yellow
} else {
    Write-Host '  Everything removed.' -ForegroundColor Green
}
if (Test-Path (Join-Path $env:LOCALAPPDATA '3D-Desktop')) {
    Write-Host '  Note: if you also want to remove it from the Lively library,'
    Write-Host '        right-click it there > Remove.' -ForegroundColor DarkGray
}
Write-Host ''
Start-Sleep -Seconds 6

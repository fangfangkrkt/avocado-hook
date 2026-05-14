@echo off
setlocal enabledelayedexpansion

echo.
echo  ===========================================
echo   Avocado Hook for Claude Code - Windows
echo  ===========================================
echo.
echo  This script will:
echo    * Save the hook script to %USERPROFILE%\.claude\avocado-hook\
echo    * Add a Stop hook to %USERPROFILE%\.claude\settings.json
echo    * Back up your settings.json before modifying
echo.
set /p REPLY= Continue? (y/n):
if /i not "%REPLY%"=="y" (
  echo Installation cancelled.
  pause
  exit /b 0
)

echo.
echo  Checking Claude Code...
if not exist "%USERPROFILE%\.claude" (
  echo  ERROR: ~/.claude not found. Is Claude Code installed?
  pause
  exit /b 1
)

echo  Installing...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$hookDir = \"$env:USERPROFILE\.claude\avocado-hook\"; ^
   New-Item -ItemType Directory -Force -Path $hookDir | Out-Null; ^
   $ps1 = @' ^
Add-Type -AssemblyName System.Windows.Forms ^
$balloon = New-Object System.Windows.Forms.NotifyIcon ^
$balloon.Icon = [System.Drawing.SystemIcons]::Application ^
$balloon.BalloonTipTitle = 'Claude Code' ^
$balloon.BalloonTipText = 'Claude has finished!' ^
$balloon.Visible = $true ^
$balloon.ShowBalloonTip(3000) ^
Start-Sleep -Milliseconds 100 ^
Start-Process 'https://fangfangkrkt.github.io/avocado-hook/fireworks.html' ^
Start-Sleep -Milliseconds 3500 ^
$balloon.Dispose() ^
'@ ^
   $ps1 | Set-Content -Path \"$hookDir\avocado-hook.ps1\" -Encoding UTF8; ^
   $settingsPath = \"$env:USERPROFILE\.claude\settings.json\"; ^
   if (Test-Path $settingsPath) { ^
     Copy-Item $settingsPath \"$settingsPath.bak\" ^
     $s = Get-Content $settingsPath -Raw | ConvertFrom-Json ^
   } else { ^
     $s = [PSCustomObject]@{} ^
   } ^
   if (-not $s.hooks) { $s | Add-Member -NotePropertyName hooks -NotePropertyValue ([PSCustomObject]@{}) } ^
   $cmd = \"powershell -WindowStyle Hidden -File `\"$hookDir\avocado-hook.ps1`\"\"; ^
   $newHook = [PSCustomObject]@{ matcher = ''; hooks = @(@{ type = 'command'; command = $cmd; timeout = 5 }) }; ^
   if (-not $s.hooks.Stop) { ^
     $s.hooks | Add-Member -NotePropertyName Stop -NotePropertyValue @($newHook) ^
   } else { ^
     $already = $s.hooks.Stop | ForEach-Object { $_.hooks } | Where-Object { $_.command -like '*avocado-hook*' }; ^
     if (-not $already) { $s.hooks.Stop += $newHook } ^
   } ^
   $s | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8; ^
   Write-Host '  Hook installed! (backup saved to settings.json.bak)'"

if %errorlevel% neq 0 (
  echo.
  echo  ERROR: Something went wrong. Try running as Administrator.
  pause
  exit /b 1
)

echo.
echo  Done! Restart Claude Code to activate.
echo  You will get a notification + fireworks every time Claude finishes.
echo.
pause

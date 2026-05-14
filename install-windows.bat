@echo off
setlocal enabledelayedexpansion

echo.
echo  ===========================================
echo   Avocado Hook for Claude Code - Windows
echo  ===========================================
echo.
echo  This script will:
echo    * Copy the hook script to %USERPROFILE%\.claude\avocado-hook\
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
  echo  ERROR: ^~/.claude not found. Is Claude Code installed?
  pause
  exit /b 1
)

echo  Installing...

mkdir "%USERPROFILE%\.claude\avocado-hook" 2>nul
copy /y "%~dp0avocado-hook.ps1" "%USERPROFILE%\.claude\avocado-hook\avocado-hook.ps1" >nul

set "HOOK=%USERPROFILE%\.claude\avocado-hook\avocado-hook.ps1"
set "SETTINGS=%USERPROFILE%\.claude\settings.json"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$hook = '%HOOK:\=\\%'; $sp = '%SETTINGS:\=\\%'; ^
   if (Test-Path $sp) { Copy-Item $sp \"$sp.bak\"; $s = Get-Content $sp -Raw | ConvertFrom-Json } ^
   else { $s = [PSCustomObject]@{} }; ^
   if (-not $s.hooks) { $s | Add-Member -NotePropertyName hooks -NotePropertyValue ([PSCustomObject]@{}) }; ^
   $cmd = \"powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File \`\"$hook\`\"\"; ^
   $entry = [PSCustomObject]@{ matcher = ''; hooks = @(@{ type = 'command'; command = $cmd; timeout = 5 }) }; ^
   if (-not $s.hooks.Stop) { $s.hooks | Add-Member -NotePropertyName Stop -NotePropertyValue @($entry) } ^
   else { $already = $s.hooks.Stop | ForEach-Object { $_.hooks } | Where-Object { $_.command -like '*avocado-hook*' }; ^
     if (-not $already) { $s.hooks.Stop += $entry } }; ^
   $s | ConvertTo-Json -Depth 10 | Set-Content $sp -Encoding UTF8; ^
   Write-Host '  Hook installed! (backup saved to settings.json.bak)'"

if %errorlevel% neq 0 (
  echo.
  echo  ERROR: Something went wrong. Try running as Administrator.
  pause
  exit /b 1
)

echo.
echo  Done! Restart Claude Code to activate.
echo  Every time Claude finishes: sound + fireworks + Claude jumps to front.
echo.
pause

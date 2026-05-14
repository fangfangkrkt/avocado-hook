Add-Type -AssemblyName System.Windows.Forms

# Sound
[System.Media.SystemSounds]::Asterisk.Play()

# Balloon notification
$balloon = New-Object System.Windows.Forms.NotifyIcon
$balloon.Icon = [System.Drawing.SystemIcons]::Application
$balloon.BalloonTipTitle = "Claude Code"
$balloon.BalloonTipText = "Claude has finished!"
$balloon.Visible = $true
$balloon.ShowBalloonTip(3000)

# Fireworks in browser
Start-Process "https://fangfangkrkt.github.io/avocado-hook/fireworks.html"

# Bring Claude to front
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@
$claude = Get-Process -Name "Claude" -ErrorAction SilentlyContinue
if ($claude) {
    [Win32]::ShowWindow($claude.MainWindowHandle, 9)
    [Win32]::SetForegroundWindow($claude.MainWindowHandle)
}

Start-Sleep -Milliseconds 3500
$balloon.Dispose()

# =====================================================
# Wolf & Co. - Unified Installer (Admin Prompt Version)
# Author: Yasser Boutarf
# Purpose: Install Dell Command Update + ScreenConnect from F drive (non-silent)
# =====================================================

# 1️⃣ Ensure Admin Privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting PowerShell as Administrator..." -ForegroundColor Red
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# ===========================================
# Section 1: Dell Command Update
# ===========================================
Write-Host "`n===================================" -ForegroundColor Yellow
Write-Host " Wolf & Co. - Dell Command Update " -ForegroundColor Cyan
Write-Host "===================================`n" -ForegroundColor Yellow

# Prefer F: drive, fallback to UNC path if inaccessible
$sourceDellPath = "F:\ADMIN\IS - Public\IS Department Team Folders\ZachH\Dell Command Update 5.4\Dell-Command-Update-Application_6VFWW_WIN_5.4.0_A00 (1).EXE"
if (-not (Test-Path $sourceDellPath)) {
    $sourceDellPath = "\\wolfco.local\ADMIN\IS - Public\IS Department Team Folders\ZachH\Dell Command Update 5.4"
    Write-Host "⚠️ F: drive not available, using UNC path: $sourceDellPath"
}

$dellInstaller = Get-ChildItem -Path $sourceDellPath -Filter "*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $dellInstaller) {
    Write-Host "❌ Dell Command Update installer not found in $sourceDellPath" -ForegroundColor Red
    pause
    exit 1
}
$localDell = "$env:TEMP\DellCommandUpdate.exe"
Copy-Item -Path $dellInstaller.FullName -Destination $localDell -Force
Write-Host "✅ Copied Dell Command Update installer to temp."

# Create progress UI
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
$window = New-Object System.Windows.Window
$window.Title = "Wolf & Co Installer"
$window.Height = 150
$window.Width = 420
$window.WindowStartupLocation = "CenterScreen"
$window.ResizeMode = "NoResize"
$window.Topmost = $true

$stack = New-Object System.Windows.Controls.StackPanel
$text = New-Object System.Windows.Controls.TextBlock
$text.FontSize = 14
$text.Margin = "0,10,0,10"
$text.HorizontalAlignment = "Center"
$text.Text = "Starting installation..."
$bar = New-Object System.Windows.Controls.ProgressBar
$bar.Height = 25
$bar.Width = 360
$bar.Minimum = 0
$bar.Maximum = 100
$bar.Value = 0
$stack.Children.Add($text)
$stack.Children.Add($bar)
$window.Content = $stack
$null = $window.Show()

function Update-ProgressUI($percent, $message) {
    $window.Dispatcher.Invoke({
        $bar.Value = $percent
        $text.Text = $message
    })
}

# Run Dell Command Update (with visible admin prompt)
try {
    Update-ProgressUI 20 "Launching Dell Command Update installer..."
    Start-Process -FilePath $localDell -Verb RunAs -Wait
    Update-ProgressUI 70 "Verifying installation..."
    $dcuPath = "C:\Program Files\Dell\CommandUpdate\dcu-ui.exe"
    if (Test-Path $dcuPath) {
        Update-ProgressUI 100 "✅ Dell Command Update installed successfully!"
        Start-Sleep -Seconds 2
        Start-Process -FilePath $dcuPath
    } else {
        [System.Windows.MessageBox]::Show("⚠️ Dell Command Update installed but GUI not found.", "Wolf & Co Installer", 'OK', 'Warning')
    }
} catch {
    [System.Windows.MessageBox]::Show("❌ Dell Command Update failed: $($_.Exception.Message)", "Wolf & Co Installer", 'OK', 'Error')
    $window.Close()
    pause
    exit 1
}

# ===========================================
# Section 2: ScreenConnect Client Installer
# ===========================================
Write-Host "`n===================================" -ForegroundColor Yellow
Write-Host " Wolf & Co. - ScreenConnect Installer " -ForegroundColor Cyan
Write-Host "===================================`n" -ForegroundColor Yellow

$sourceScreenPath = "F:\ADMIN\IS - Public\IS Department Team Folders\ZachH\CW Installs"
if (-not (Test-Path $sourceScreenPath)) {
    $sourceScreenPath = "\\wolfco.local\ADMIN\IS - Public\IS Department Team Folders\ZachH\CW Installs"
    Write-Host "⚠️ F: drive not available, using UNC path: $sourceScreenPath"
}
$fileName = "BostonScreenConnect.ClientSetup.msi"
$sourceFile = Join-Path $sourceScreenPath $fileName
$localFile = "$env:TEMP\$fileName"

try {
    Update-ProgressUI 10 "Copying ScreenConnect installer..."
    Copy-Item -Path $sourceFile -Destination $localFile -Force
    Start-Sleep -Seconds 1
    Update-ProgressUI 40 "Launching ScreenConnect installer..."
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$localFile`"" -Verb RunAs -Wait
    Update-ProgressUI 80 "Verifying ScreenConnect service..."
    $svc = Get-Service -Name "ScreenConnect Client*" -ErrorAction SilentlyContinue
    if ($svc) {
        Update-ProgressUI 100 "✅ ScreenConnect installed successfully!"
        [System.Windows.MessageBox]::Show("✅ ScreenConnect Client installed successfully!", "Wolf & Co Installer", 'OK', 'Information')
    } else {
        [System.Windows.MessageBox]::Show("⚠️ ScreenConnect installed but service not detected.", "Wolf & Co Installer", 'OK', 'Warning')
    }
} catch {
    [System.Windows.MessageBox]::Show("❌ ScreenConnect installation failed: $($_.Exception.Message)", "Wolf & Co Installer", 'OK', 'Error')
}

$window.Close()
Write-Host "`n🎉 All installations complete! You can now close this window." -ForegroundColor Cyan
pause

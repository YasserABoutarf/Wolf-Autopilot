# =====================================================
# Wolf & Co. - Unified Installer (Local Copy Version)
# Author: Yasser Boutarf
# Purpose: Install Dell Command Update + ScreenConnect directly from F drive
# =====================================================

# 1️⃣ Ensure Admin Privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting PowerShell as Administrator..." -ForegroundColor Red
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iwr -useb https://raw.githubusercontent.com/YasserBoutarf/Wolf-Autopilot/main/DellUpdateScreenConnect.ps1 | iex`""
    exit
}

# ===========================================
# Section 1: Dell Command Update
# ===========================================
Write-Host "`n===================================" -ForegroundColor Yellow
Write-Host " Wolf & Co. - Dell Command Update " -ForegroundColor Cyan
Write-Host "===================================`n" -ForegroundColor Yellow

$sourceDellPath = "F:\ADMIN\IS - Public\IS Department Team Folders\ZachH\Dell Command Update 5.4"
$dellInstaller = Get-ChildItem -Path $sourceDellPath -Filter "*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $dellInstaller) {
    Write-Host "❌ Dell Command Update installer not found in $sourceDellPath" -ForegroundColor Red
    exit 1
}
$localDell = "$env:TEMP\DellCommandUpdate.exe"

# Create UI
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
$text.Text = "Preparing installation..."
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

# Copy Dell Command Update
try {
    Update-ProgressUI 10 "Locating Dell Command Update installer..."
    if (-not (Test-Path $dellInstaller.FullName)) { throw "Installer not found: $($dellInstaller.FullName)" }
    Update-ProgressUI 25 "Copying Dell Command Update installer..."
    Copy-Item -Path $dellInstaller.FullName -Destination $localDell -Force
    Start-Sleep -Seconds 1
    Update-ProgressUI 50 "Installing Dell Command Update..."
    Start-Process -FilePath $localDell -ArgumentList "/S" -Wait
    Update-ProgressUI 80 "Verifying installation..."
    $dcuPath = "C:\Program Files\Dell\CommandUpdate\dcu-ui.exe"
    if (Test-Path $dcuPath) {
        Update-ProgressUI 100 "✅ Dell Command Update installed successfully!"
        Start-Sleep -Seconds 1.5
        Start-Process -FilePath $dcuPath
    } else {
        [System.Windows.MessageBox]::Show("⚠️ Dell Command Update installed but GUI not found.", "Wolf & Co Installer", 'OK', 'Warning')
    }
} catch {
    [System.Windows.MessageBox]::Show("❌ Dell Command Update failed: $($_.Exception.Message)", "Wolf & Co Installer", 'OK', 'Error')
    $window.Close()
    exit 1
}

# ===========================================
# Section 2: ScreenConnect Client Installer
# ===========================================
Write-Host "`n===================================" -ForegroundColor Yellow
Write-Host " Wolf & Co. - ScreenConnect Installer " -ForegroundColor Cyan
Write-Host "===================================`n" -ForegroundColor Yellow

$sourceScreenPath = "F:\ADMIN\IS - Public\IS Department Team Folders\ZachH\CW Installs"
$fileName = "BostonScreenConnect.ClientSetup.msi"
$sourceFile = Join-Path $sourceScreenPath $fileName
$localFile = "$env:TEMP\$fileName"

try {
    Update-ProgressUI 10 "Locating ScreenConnect installer..."
    if (-Not (Test-Path $sourceFile)) { throw "Installer not found at: $sourceFile" }

    Update-ProgressUI 30 "Copying ScreenConnect installer..."
    Copy-Item -Path $sourceFile -Destination $localFile -Force
    Start-Sleep -Seconds 1
    Update-ProgressUI 60 "Installing ScreenConnect Client..."
    Start-Process msiexec.exe -ArgumentList "/i `"$localFile`" /qn /norestart" -Wait
    Update-ProgressUI 90 "Verifying ScreenConnect service..."
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

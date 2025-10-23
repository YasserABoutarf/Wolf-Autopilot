# =====================================================
# Wolf & Co. Unified Installer Script
# Author: Yasser Boutarf
# Purpose: Install Dell Command Update + ScreenConnect
# =====================================================

# 1️⃣ Ensure Admin Privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting PowerShell as Administrator..." -ForegroundColor Red
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iwr -useb https://raw.githubusercontent.com/YasserBoutarf/Wolf-Autopilot/main/WolfUnifiedInstaller.ps1 | iex`""
    exit
}

# 2️⃣ Dell Command Update Installer
Write-Host "`n===================================" -ForegroundColor Yellow
Write-Host " Wolf & Co. - Dell Command Update " -ForegroundColor Cyan
Write-Host "===================================`n" -ForegroundColor Yellow

$DownloadPath = "C:\Temp"
if (!(Test-Path -Path $DownloadPath)) { New-Item -ItemType Directory -Path $DownloadPath | Out-Null }

$InstallerUrl = "https://downloads.dell.com/FOLDER09348912M/1/Dell-Command-Update-Windows-Universal-Application_T96CK_WIN_5.3.0_A00.EXE"
$InstallerPath = "$DownloadPath\DellCommandUpdate.exe"

Write-Host "📦 Downloading Dell Command Update..."
Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerPath -UseBasicParsing
Write-Host "✅ Download complete. Installing Dell Command Update..."
Start-Process -FilePath $InstallerPath -ArgumentList "/S" -Wait
Write-Host "🎉 Dell Command Update installed successfully!"

# Open DCU GUI side-by-side
Start-Sleep -Seconds 5
$DcuPath = "C:\Program Files\Dell\CommandUpdate\dcu-ui.exe"
if (Test-Path $DcuPath) {
    Write-Host "🚀 Launching Dell Command Update side-by-side..."
    Start-Process -FilePath $DcuPath
} else {
    Write-Host "⚠️ Could not find Dell Command Update GUI."
}

Write-Host "`n👉 Reminder: Skip these updates if they appear:"
Write-Host "   - Intel Management Components"
Write-Host "   - Intel Rapid Storage / Management Console"
Write-Host "   - Intel HID Event Filter"
Write-Host "   - Dell Pair Application"
Write-Host ""

# ===========================================
# Wolf & Co. - ScreenConnect Client Installer
# ===========================================

Write-Host "`n===================================" -ForegroundColor Yellow
Write-Host " Wolf & Co. - ScreenConnect Installer " -ForegroundColor Cyan
Write-Host "===================================`n" -ForegroundColor Yellow

# 3️⃣ Define Paths
$networkPath = "F:\ADMIN\IS-Public\IS Department Team Folders\ZachH\CW Installs"
$fileName = "BostonScreenConnect.ClientSetup.msi"
$sourceFile = Join-Path $networkPath $fileName
$localPath = "$env:TEMP\$fileName"
$logPath = "$env:ProgramData\WolfCo\ScreenConnect_Install.log"

# Ensure log directory exists
New-Item -Path (Split-Path $logPath) -ItemType Directory -Force | Out-Null
Start-Transcript -Path $logPath -Append

# 4️⃣ Create Progress UI
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

# Run UI in background thread
$job = Start-Job { param($window) [void][System.Windows.Threading.Dispatcher]::Run() } -ArgumentList $window
$window.Show()

function Update-ProgressUI($percent, $message) {
    $window.Dispatcher.Invoke({
        $bar.Value = $percent
        $text.Text = $message
    })
}

# 5️⃣ Copy Installer
try {
    Update-ProgressUI 10 "Locating installer..."
    if (-Not (Test-Path $sourceFile)) {
        throw "Installer not found at: $sourceFile"
    }

    Update-ProgressUI 30 "Copying ScreenConnect installer..."
    Copy-Item -Path $sourceFile -Destination $localPath -Force
    Start-Sleep -Seconds 1
    Update-ProgressUI 50 "Installer copied successfully."
}
catch {
    $window.Close()
    [System.Windows.MessageBox]::Show("❌ Failed to copy installer: $($_.Exception.Message)", "Wolf & Co Installer", 'OK', 'Error')
    Stop-Transcript
    exit 1
}

# 6️⃣ Install ScreenConnect Client
Update-ProgressUI 70 "Installing ScreenConnect Client..."
$installArgs = "/i `"$localPath`" /qn /norestart"
$process = Start-Process msiexec.exe -ArgumentList $installArgs -Wait -PassThru

if ($process.ExitCode -ne 0) {
    $window.Close()
    [System.Windows.MessageBox]::Show("❌ Installation failed with exit code $($process.ExitCode).", "Wolf & Co Installer", 'OK', 'Error')
    Stop-Transcript
    exit 1
}

# 7️⃣ Verify Installation
Update-ProgressUI 90 "Verifying installation..."
$service = Get-Service -Name "ScreenConnect Client*" -ErrorAction SilentlyContinue
if ($service) {
    Update-ProgressUI 100 "✅ Installation complete!"
    Start-Sleep -Seconds 1.5
    $window.Close()
    [System.Windows.MessageBox]::Show("✅ ScreenConnect Client installed successfully!", "Wolf & Co Installer", 'OK', 'Information')
} else {
    $window.Close()
    [System.Windows.MessageBox]::Show("⚠️ Installation completed but service not found. Please verify manually.", "Wolf & Co Installer", 'OK', 'Warning')
}

Stop-Transcript
Write-Host "`n🎉 Installation complete! You can now close this window." -ForegroundColor Cyan


# ===========================================
# Wolf & Co. - Autopilot Import Script (Phase 1)
# Author: Yasser Boutarf
# ===========================================

Write-Host "`n===================================" -ForegroundColor Yellow
Write-Host "Starting Wolf & Co Autopilot Import..." -ForegroundColor Cyan
Write-Host "===================================`n" -ForegroundColor Yellow

# 1️⃣ Ensure admin privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting PowerShell as Administrator..." -ForegroundColor Red
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iwr -useb https://raw.githubusercontent.com/YasserBoutarf/Wolf-Autopilot/main/Autopilot-Import.ps1 | iex`""
    exit
}

# 2️⃣ Install NuGet provider silently
Write-Host "Installing NuGet provider..." -ForegroundColor Cyan
Install-PackageProvider -Name NuGet -Force -Confirm:$false | Out-Null

# 3️⃣ Install the Windows Autopilot script silently
Write-Host "Installing Windows Autopilot module..." -ForegroundColor Cyan
Install-Script -Name Get-WindowsAutopilotInfo -Force -Confirm:$false | Out-Null

# 4️⃣ Set execution policy for current session
Write-Host "Setting Execution Policy..." -ForegroundColor Cyan
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force | Out-Null

# 5️⃣ Verify internet connection (Ethernet)
Write-Host "Checking network connection..." -ForegroundColor Cyan
if (!(Test-Connection -ComputerName "microsoft.com" -Count 1 -Quiet)) {
    Write-Host "⚠️ No internet detected! Please connect via Ethernet and re-run this script." -ForegroundColor Red
    exit
} else {
    Write-Host "✅ Internet connection verified." -ForegroundColor Green
}

# 6️⃣ Import device into Autopilot
Write-Host "`nImporting device into Autopilot..." -ForegroundColor Cyan
try {
    Get-WindowsAutopilotInfo -Online
    Write-Host "`n✅ Device successfully imported into Autopilot!" -ForegroundColor Green
} catch {
    Write-Host "`n❌ Error importing device. Details:" -ForegroundColor Red
    Write-Host $_
}

Write-Host "`n-----------------------------------" -ForegroundColor Yellow
Write-Host "Autopilot Import Complete!" -ForegroundColor Green
Write-Host "You may now proceed to tagging in Intune." -ForegroundColor Yellow
Write-Host "-----------------------------------`n" -ForegroundColor Yellow


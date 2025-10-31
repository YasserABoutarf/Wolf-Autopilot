# ===========================================
# Wolf & Co. - Autopilot Import Script (Phase 1)
# Author: Yasser Boutarf
# ===========================================

Write-Host "`n===================================" -ForegroundColor Yellow
Write-Host "Starting Wolf & Co Autopilot Import..." -ForegroundColor Cyan
Write-Host "===================================`n" -ForegroundColor Yellow

# admin privelages needed
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting PowerShell as Administrator..." -ForegroundColor Red
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iwr -useb https://raw.githubusercontent.com/YasserABoutarf/Wolf-Autopilot/main/Autopilot-Import.ps1 | iex`""
    exit
}

# installs nuget provider
Write-Host "Installing NuGet provider..." -ForegroundColor Cyan
Install-PackageProvider -Name NuGet -Force -Confirm:$false | Out-Null

# installs window autopilot
Write-Host "Installing Windows Autopilot module..." -ForegroundColor Cyan
Install-Script -Name Get-WindowsAutopilotInfo -Force -Confirm:$false | Out-Null

# sets execution policy
Write-Host "Setting Execution Policy..." -ForegroundColor Cyan
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force | Out-Null

# internet connection is required via ethernet so that we can pull from  web
Write-Host "checking network connection..." -ForegroundColor Cyan
try {
    $null = Invoke-WebRequest -Uri "https://www.microsoft.com" -UseBasicParsing -TimeoutSec 10
    Write-Host "internet connection verified." -ForegroundColor Green
}
catch {
    Write-Host "internet test failed. Please confirm Ethernet is connected and try again." -ForegroundColor Red
    exit
}

# once email is entered device will begin to import
Write-Host "`nImporting device into Autopilot..." -ForegroundColor Cyan
try {
    Get-WindowsAutopilotInfo -Online
    Write-Host "`nDevice successfully imported into Autopilot!" -ForegroundColor Green
} catch {
    Write-Host "`n Error importing device. Details:" -ForegroundColor Red
    Write-Host $_
}

Write-Host "`n-----------------------------------" -ForegroundColor Yellow
Write-Host "Autopilot Import Complete!" -ForegroundColor Green
Write-Host "You may now proceed to tagging in Intune." -ForegroundColor Yellow
Write-Host "-----------------------------------`n" -ForegroundColor Yellow

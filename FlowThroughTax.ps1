$installerPath1 = "F:\APPS\TValue 6\TValue6-02-Setup.exe"
$installerPath2 = "C:\Program Files\Backup\Caseware 2024 Files\ConnectorSetup.exe"
$installerPath3 = "C:\Program Files\Backup\Caseware 2024 Files\WP2024USSYNC_EF4E1C8024CAF2620E0F_.exe"
$installerPath4 = "C:\Program Files\Backup\Caseware 2024 Files\CW2024TaxUpdate.exe"
$installerPath5 = "\\bos-ichannel\ichannel\web\ConarciFetch\Prerequisites\windowsdesktop-runtime-8.0.5-win-x64.exe"
$installerPath6 = "\\bos-ichannel\ichannel\web\ConarciFetch\Setup\ConarciFetchInstaller.exe"


# Tvalue Install
If(Test-Path $installerPath1) {
    Write-Host "T Value Found. Downloading..."
    Start-Process -FilePath $installerPath1 -Wait
    Write-Host "Setup Complete"
} else {
    Write-Host "Installer failed."
}
# Caseware Install
If(Test-Path $installerPath2) {
    Write-Host "Downloading Caseware...."
    Start-Process -FilePath $installerPath2 -Wait
    Write-Host "Setup Complete"
} else {
    Write-Host "Installer Failed"
}

#Caseware connecter install
If(Test-Path $installerPath3) {
    Write-Host "Downloading Caseware...."
    Start-Process -FilePath $installerPath3 -Wait
    Write-Host "Setup Complete"
} else {
    Write-Host "Installer Failed"
}

#Tax update
If(Test-Path $installerPath4) {
    Write-Host "Downloading Caseware...."
    Start-Process -FilePath $installerPath4 -Wait
    Write-Host "Setup Complete"
} else {
    Write-Host "Installer Failed"
}

#Ichannel prereqs
If(Test-Path $installerPath5) {
    Write-Host "Downloading Ichannel prereqs...."
    Start-Process -FilePath $installerPath5 -Wait
    Write-Host "Setup Complete"
} else {
    Write-Host "Installer Failed"
}

#ichannel
If(Test-Path $installerPath6) {
    Write-Host "Downloading Ichannel..."
    Start-Process -FilePath $installerPath6 -Wait
    Write-Host "Setup finished"
} else {
    Write-Host "Installer Failed"
}

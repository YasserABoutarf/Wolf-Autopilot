$installerPath4 = "\\bos-ichannel\ichannel\web\ConarciFetch\Prerequisites\windowsdesktop-runtime-8.0.5-win-x64.exe"

If(Test-Path $installerPath4) {
    Write-Host "Downloading Ichannel prereqs...."
    Start-Process -FilePath $installerPath4 -Wait
    Write-Host "Setup Complete"
} else {
    Write-Host "Installer Failed"
}

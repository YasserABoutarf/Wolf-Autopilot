$installerPath = "F:\APPS\TValue 6\TValue6-02-Setup.exe"


if (Test-Path $installerPath) {
    Write-Host "Installer found. Running setup..."
    Start-Process -FilePath $installerPath -Wait
    Write-Host "Setup completed."
} else {
    Write-Host "Installer not found at path: $installerPath"

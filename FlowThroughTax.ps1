$installerPath = "F:\APPS\TValue 6\TValue6-02-Setup.exe"

# Tvalue Install
If(Test-Path $installerPath) {
    Write-Host "T Value Found. Downloading..."
    Start-Process -FilePath $installerPath -Wait
    Write-Host "Setup Complete"
} else {
    Write-Host "Installer failed."
}

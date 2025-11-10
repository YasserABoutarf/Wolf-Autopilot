$tvalue = "F:\APPS\TValue 6\TValue6-02-Setup.exe"
$ichannelprereq = "\\bos-ichannel\ichannel\web\ConarciFetch\Prerequisites\windowsdesktop-runtime-8.0.5-win-x64.exe"
$ichannel = "\\bos-ichannel\ichannel\web\ConarciFetch\Setup\ConarciFetchInstaller.exe"
 
#downloads tvalue
If(Test-Path $tvalue) {
    Write-Host "T Value Found. Downloading..."
    Start-Process -FilePath $tvalue -Wait
    Write-Host "Setup Complete"
} else {
    Write-Host "Installer failed."
}


#downloads ichannel prereqs
If(Test-Path $ichannelprereq) {
    Write-Host "Ichannel Prereqs are downloading..."
    Start-Process -FilePath $ichannelprereq -Wait
    Write-Host "Setup is complete"
} else {
    Write-Host "Download failed" 
}

#Downloads ichannel
If(Test-Path $ichannel) {
    Write-Host "Ichannel Prereqs are downloading..."
    Start-Process -FilePath $ichannel -Wait
    Write-Host "Setup is complete"
} else {
    Write-Host "Download failed" 
}

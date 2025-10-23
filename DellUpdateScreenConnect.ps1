# ===========================================
# Wolf & Co. - Dell Command Update + ScreenConnect Installer
# Author: Yasser Boutarf
# ===========================================

Write-Host "`n===================================" -ForegroundColor Yellow
Write-Host "Wolf & Co. - Laptop Auto Installer" -ForegroundColor Cyan
Write-Host "===================================`n" -ForegroundColor Yellow

# 1️⃣ Ensure Admin Privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting PowerShell as Administrator..." -ForegroundColor Red
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# 2️⃣ Paths
$DellCmdExe = "F:\ADMIN\IS - Public\IS Department Team Folders\ZachH\Dell Command Update 5.4\Dell-Command-Update-Application_6VFWW_WIN_5.4.0_A00 (1).EXE"
$ScreenConnectMsi = "F:\ADMIN\IS - Public\IS Department Team Folders\ZachH\CW Installs\BostonScreenConnect.ClientSetup.msi"

# Local permanent folder
$LocalDir = "C:\WolfInstallers"
$Log = Join-Path $LocalDir "InstallLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# Create folder if missing
New-Item -Path $LocalDir -ItemType Directory -Force | Out-Null

Function Log {
    param([string]$Message)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time`t$Message" | Tee-Object -FilePath $Log -Append
}

Function Copy-WithCred {
    param([string]$SourcePath)
    $dest = Join-Path $LocalDir (Split-Path $SourcePath -Leaf)

    if (Test-Path $SourcePath) {
        Write-Host "Copying $SourcePath..." -ForegroundColor Yellow
        try {
            Copy-Item -Path $SourcePath -Destination $dest -Force
            Log "Copied $SourcePath to $dest"
        } catch {
            Log "Copy failed: $_"
        }
    } else {
        # Fallback UNC form if F: drive not visible
        $uncPath = $SourcePath -replace '^F:', '\\wolf.local\ADMIN'
        Write-Host "Attempting UNC path: $uncPath" -ForegroundColor Yellow
        $cred = Get-Credential -Message "Enter credentials to access $uncPath (Local Admin)"
        try {
            New-PSDrive -Name "TempF" -PSProvider FileSystem -Root (Split-Path $uncPath -Parent) -Credential $cred -ErrorAction Stop | Out-Null
            Copy-Item -Path ("TempF:\" + (Split-Path $uncPath -Leaf)) -Destination $dest -Force
            Remove-PSDrive -Name "TempF" -Force
            Log "Copied via UNC to $dest"
        } catch {
            Log "UNC copy failed: $_"
        }
    }
    return $dest
}

# 3️⃣ Copy installers to local C: folder
$dellLocal = Copy-WithCred $DellCmdExe
$scLocal   = Copy-WithCred $ScreenConnectMsi

# 4️⃣ Install Dell Command Update (.EXE)
if (Test-Path $dellLocal) {
    Write-Host "`nInstalling Dell Command Update..." -ForegroundColor Cyan
    try {
        Start-Process -FilePath $dellLocal -ArgumentList "/S" -Wait -PassThru | Out-Null
        Log "Dell Command Update installed successfully."
    } catch {
        Log "Dell Command Update install failed: $_"
    }
} else {
    Log "Dell installer not found!"
}

# 5️⃣ Install ScreenConnect (.MSI)
if (Test-Path $scLocal) {
    Write-Host "`nInstalling ScreenConnect Client..." -ForegroundColor Cyan
    try {
        Start-Process msiexec.exe -ArgumentList "/i `"$scLocal`" /qn /norestart" -Wait -PassThru | Out-Null
        Log "ScreenConnect installed successfully."
    } catch {
        Log "ScreenConnect install failed: $_"
    }
} else {
    Log "ScreenConnect MSI not found!"
}

# 6️⃣ Finish
Write-Host "`nAll tasks completed successfully." -ForegroundColor Green
Write-Host "Installers saved at: $LocalDir" -ForegroundColor Yellow
Write-Host "Log file saved at: $Log" -ForegroundColor Yellow

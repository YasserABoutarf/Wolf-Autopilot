function Add-PrinterIfPortExists {
    param (
        [string]$PrinterName,
        [string]$PrinterIP,
        [string]$PrinterPort,
        [string]$PrinterDriver
    )

    if (-not (Get-PrinterPort -Name $PrinterPort -ErrorAction SilentlyContinue)) {
        Add-PrinterPort -Name $PrinterPort -PrinterHostAddress $PrinterIP
    }

    Add-Printer -Name $PrinterName -DriverName $PrinterDriver -PortName $PrinterPort
}

Add-PrinterIfPortExists "Copier-Production on BOS-FS2" "192.168.4.10" "IP_192.168.4.10" "TOSHIBA e-STUDIO Universal PCL6"
Add-PrinterIfPortExists "Printer-Harbor1 on BOS-FS2" "192.168.4.5" "IP_192.168.4.5" "HP LaserJet M806 PCL 6"
Add-PrinterIfPortExists "Printer-Harbor2 on BOS-FS2" "192.168.4.6" "IP_192.168.4.6" "HP Universal Printing PCL 6 (v6.7.0)"
Add-PrinterIfPortExists "Printer-Harbor3 on BOS-FS2" "192.168.4.7" "IP_192.168.4.7" "HP Universal Printing PCL 6 (v6.7.0)"
Add-PrinterIfPortExists "Printer-Library on BOS-FS2" "192.168.4.8" "IP_192.168.4.8" "HP Universal Printing PCL 6 (v6.7.0)"
Add-PrinterIfPortExists "Copier-Library on BOS-FS2" "192.168.4.11" "IP_192.168.4.11" "TOSHIBA e-STUDIO Universal PCL6"


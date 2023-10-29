# a script to run Repair-WindowsImage & sfc /scannow 

Start-Transcript -Path "C:\Temp\dism+sfc.log" -Append:$true

"Starting Repair-WindowsImage"

Repair-WindowsImage -RestoreHealth -Online -Verbose

"Starting sfc /scannow"

$sfc = (C:\Windows\System32\sfc.exe /scannow)

$sfc | Where-Object {$_ -replace "`0"} | Select-Object -First 3 -Last 2
# $sfc -replace "`0" | Where-Object {$_} | Select-Object -First 3 -Last 2
# $sfc -replace "`0" | Where-Object {$_ -ne ""} | Select-Object -First 3 -Last 2

Stop-Transcript
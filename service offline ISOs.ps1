# a script to service offline ISOs

# Self-elevate the script if required https://blog.expta.com/2017/03/how-to-self-elevate-powershell-script.html
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
	if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
		$CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
		Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
	 	Exit
	}
}
Start-Transcript -Path D:\DISM.log

$ExtractedISO 	= "D:\Extracted ISO\Win10_22H2_English_x64" # no trailing slash
$ExtractedWIM 	= "D:\Extracted ISO\Win10_22H2_English_x64\sources\install.wim"
$MountedWIM 	= "D:\Mounted WIM\"
$ISOFileOutput 	= "D:\Win10_22H2.iso"
$BootSectorFile = "D:\efisys_noprompt.bin"
$OscdimgEXE 	= "D:\oscdimg.exe"
$OscdimgArgs	= "-b$BootSectorFile", "-pEF", "-u1", "-udfver102", $ExtractedISO, $ISOFileOutput
$ImageIndex 	= (Get-WindowsImage -ImagePath $ExtractedWIM | Where-Object {$_.ImageName -eq "Windows 10 Pro"})
$ExportedWIM 	= "D:\Extracted ISO\Win10_22H2_English_x64\sources\install new.wim"

Mount-WindowsImage -Path $MountedWIM -ImagePath $ExtractedWIM -Index $ImageIndex.ImageIndex -CheckIntegrity

$MSUs=@(
	# put SSU first
	"D:\updates\ssu-19041.1704-x64_70e350118b85fdae082ab7fde8165a947341ba1a.msu"
	"D:\updates\windows10.0-kb5022282-x64_fdb2ea85e921869f0abe1750ac7cee34876a760c.msu"
)

foreach ($MSU in $MSUs) { Add-WindowsPackage -PackagePath $MSU -Path $MountedWIM -Verbose }

$BloatwareShortName = @(
  "Microsoft.BingWeather"
  "Microsoft.GetHelp"
  "Microsoft.Getstarted"
  "Microsoft.Microsoft3DViewer"
  "Microsoft.MicrosoftOfficeHub"
  "Microsoft.MixedReality.Portal"
  "Microsoft.People"
  "Microsoft.SkypeApp"
  "Microsoft.Wallet"
  "microsoft.windowscommunicationsapps"
  "Microsoft.WindowsFeedbackHub"
  "Microsoft.WindowsMaps"
  "Microsoft.Xbox.TCUI"
  "Microsoft.XboxApp"
  "Microsoft.XboxGameOverlay"
  "Microsoft.XboxGamingOverlay"
  "Microsoft.XboxIdentityProvider"
  "Microsoft.XboxSpeechToTextOverlay"
  "Microsoft.YourPhone"
)

# this step is needed because Remove-AppxProvisionedPackage only accepts full package names
$Bloatware= (Get-AppxProvisionedPackage -Path $MountedWIM | Where-Object {$BloatwareShortName -contains $_.DisplayName})

foreach ($Bloat in $Bloatware) { Remove-AppxProvisionedPackage -Path $MountedWIM -PackageName $Bloat.PackageName }

Dismount-WindowsImage -Path $MountedWIM -Save -CheckIntegrity

# export to reduce size
Export-WindowsImage -SourceImagePath $ExtractedWIM -SourceIndex $ImageIndex.ImageIndex -DestinationImagePath $ExtractedWIM -CheckIntegrity

# overwrite the old wim
Move-Item -Path $ExportedWIM -Destination $ExtractedWIM -Force

# create an ISO
& $OscdimgEXE $OscdimgArgs

Stop-Transcript
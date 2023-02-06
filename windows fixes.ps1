# a script to set some windows settings and remove bloatware

Start-Transcript -Path 'C:\Temp\windows fixes.log' -Append:$true

# disable fast startup

if ( (Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power") -ne $true )

{ New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Force -ErrorAction SilentlyContinue }

New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' `
  -Name 'HiberbootEnabled' -Value 0 -PropertyType DWord -Force -ErrorAction SilentlyContinue


$Bloatware = @(
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

Write-Host "Removing Bloatware"

ForEach ($Bloat in $Bloatware)
{
    $Packages = Get-AppxPackage -AllUsers -Name $Bloat

    if ($null -ne $Packages)
    {
	# this foreach is to go through all the same named packages from multiple users and the different versions, and so we can run this script as system
        foreach ($Package in $Packages)
        {
		Write-Host "Removing Appx Package: $Bloat"

        Remove-AppxPackage -AllUsers -Package $Package.PackageFullName
		}
    }
    else
    {
        Write-Host "Unable to find package: $Bloat"
	}
    $ProvisionedPackage = Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq $Bloat}

    if ($null -ne $ProvisionedPackage)
    {
        Write-Host "Removing Appx Provisioned Package: $Bloat"

        Remove-AppxProvisionedPackage -Online -PackageName $ProvisionedPackage.PackageName
    }
    else
    {
        Write-Host "Unable to find provisioned package: $Bloat"
    }
}
Stop-Transcript

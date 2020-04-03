function Show-Menu
{
     param (
           [string]$Title = 'Menu'
     )
     cls
     Write-Host "================ $Title ================"
     
     Write-Host "1: Press '1' exporting windows roles."
     Write-Host "2: Press '2' for exporting installed software."
     Write-Host "3: Press '3' for exporting running services."
     Write-Host "Q: Press 'Q' to quit."
}

cls
$location = read-host "Please select location - Example ==> C:\mypath"
do
{cls
    
     Show-Menu
     $input = Read-Host "Please make a selection"
     switch ($input)
     {
           '1' {
                cls
                Get-WindowsFeature | where {$_.InstallState -eq "Installed"} | select DisplayName | export-csv $location\roles.csv -NoTypeInformation
           } '2' {
                cls
               Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | `
               Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | export-csv $location\installedsoft.csv -NoTypeInformation
           } '3' {
                Get-Service | where {$_.status -eq "Running"} | select Displayname | export-csv $location\runningservices.csv -NoTypeInformation
                cls
               
           } 'q' {
                return
           }
     }
     pause
}
until ($input -eq 'q')

<#
Win2008R2
 Ipmo servermanager

Get-WindowsFeature | where {$_.Installed -eq $True} | select DisplayName | export-csv roles.csv -NoTypeInformation
Get-Service | where {$_.status -eq "Running"} | select Displayname| export-csv runningservices.csv -NoTypeInformation

 Get-WindowsFeature | where {$_.InstallState -eq "Installed"} | select DisplayName | export-csv roles.csv -NoTypeInformation


Get-Service | where {$_.status -eq "Running"} | select Displayname | export-csv runningservices.csv -NoTypeInformation

#>
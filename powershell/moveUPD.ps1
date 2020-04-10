#pre-requisites
import-module ActiveDirectory

#getting info needed to copy data
$user = Read-Host "What is your username?"
$userinfo = Get-ADUser $user

$sid = $userinfo.sid.Value
$vhdpath = "\\vmhrmweuprdfs03\UPDv2\UVHD-$sid.vhdx"

#mounting the VHD without letter and getting the disk number

$mountedDisk = (Mount-DiskImage -ImagePath $VHDPath -NoDriveLetter -PassThru -ErrorAction Stop | Get-DiskImage).Number


#creating a temporary folder for mount point
New-Item -Path C:\Temp -ItemType Directory -Name $user

#creating a mount point based on disknumber
Add-PartitionAccessPath -DiskNumber $mountedDisk -PartitionNumber 1 -AccessPath "C:\Temp\$user"

#copy everything that is in UPD under AppData\Roaming to Redirected Appdata
robocopy C:\Temp\$user\appdata\Roaming \\vmhrmweuprdfs03\Folderredirection\$user\appdata\Roaming /MIR /COPYALL

#copy startmenu from shared location to user profile Start Menu
robocopy \\vmhrmweuprdfs03\UPDv2\redirection\startmenu \\vmhrmweuprdfs03\Folderredirection\$user\Startmenu /MIR /COPYALL

#remove mount point
Remove-PartitionAccessPath -DiskNumber $mountedDisk -PartitionNumber 1 -AccessPath "C:\Temp\$user"

#dismount vhd
Dismount-DiskImage -ImagePath $VHDPath

#delete folder previously created
remove-item -Path C:\Temp\$user
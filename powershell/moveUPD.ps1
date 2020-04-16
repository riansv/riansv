#pre-requisites
import-module ActiveDirectory
$scriptlocation = $PSScriptRoot
remove-item $PSScriptRoot\issues.txt
#start of script

foreach($user in (get-content "$scriptlocation\users.txt")){

    try{
        #getting info needed to copy data
        $sid = (Get-ADUser $user).sid.value 

        $vhdpath = "\\vmhrmweuprdfs03\UPDv2\UVHD-$sid.vhdx"

        #mounting the VHD without letter and getting the disk number

        $mountedDisk = (Mount-DiskImage -ImagePath $VHDPath -NoDriveLetter -PassThru -ErrorAction Stop | Get-DiskImage).Number 


        #creating a temporary folder for mount point
        New-Item -Path C:\Temp -ItemType Directory -Name $user -ErrorAction Stop

        #creating a mount point based on disknumber
        Add-PartitionAccessPath -DiskNumber $mountedDisk -PartitionNumber 1 -AccessPath "C:\Temp\$user" -ErrorAction Stop

        #copy everything that is in UPD under AppData\Roaming to Redirected Appdata
        robocopy C:\Temp\$user\appdata\Roaming \\vmhrmweuprdfs03\Folderredirection\$user\appdata\Roaming /MIR /COPYALL

        #copy startmenu from shared location to user profile Start Menu
        robocopy \\vmhrmweuprdfs03\UPDv2\redirection\startmenu "\\vmhrmweuprdfs03\Folderredirection\$user\Start Menu" /MIR /COPYALL

       #configure full access over Start Menu folder
        $rights = 'icacls "\\vmhrmweuprdfs03\Folderredirection\'+$user+'\Start Menu" /grant '+$user+':F /T'
        Invoke-Expression $rights

        #remove mount point
        Remove-PartitionAccessPath -DiskNumber $mountedDisk -PartitionNumber 1 -AccessPath "C:\Temp\$user"

        #dismount vhd
        Dismount-DiskImage -ImagePath $VHDPath

        #delete folder previously created
        remove-item -Path C:\Temp\$user
    }
    Catch {
        "$user couldn't be migrated" | Out-file $scriptlocation\issues.txt -Append
    }
}

pause
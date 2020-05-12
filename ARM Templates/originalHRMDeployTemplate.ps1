Param(
  [string]$VHDStorageAccountURI,
  [string]$RDSHostname
)
#########################
#### Begin of RDSH 01 ###
#########################
# Universal Variables

$RGCompute = "RG-WEU-PRD-HRM-RDS"
$RGNetworking = "RG-WEU-PRD-HRM-NET"
$RGStorage = "RG-WEU-PRD-HRM-DATA"
$StorAccNameOS = "saplrshrmweuprdrds01"
$StorAccNameData = "saplrshrmweuprdrds01"
$osSKU = "2016-Datacenter" 
$VMSize = "Standard_D16s_v3"
$asname = "ashrmweuprdrds"
$Location = "westeurope"
$VNetName = "vnHRMWEUPRD"
$SubnetName = "SNWEUPRDRemoteDesktopServices"
$saaccountbootdiag = "salrshrmweuprddiag"
$availabilitySet = Get-AzureRmAvailabilitySet -ResourceGroupName $RGCompute -Name $asName

################
################
# VM Specific Variables

$VMName = $RDSHostname 


################
################
# Create the NIC
# Get the VNET to which to connect the NIC

$VNet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $RGNetworking
# Get the Subnet ID to which to connect the NIC
$SubnetID = (Get-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VNET).Id
# Deploy the NIC
$NIC = New-AzureRmNetworkInterface -Name "$VMName-nic" -ResourceGroupName $RGCompute -Location $Location -SubnetId $SubnetID -Force

################
################
# Specify local administrator account
 
$Username = "cgk_admin" 
$Password = "Pa55w.rd1234"
$Passwordsec = convertto-securestring $Password -asplaintext -force 
$Creds = New-Object System.Management.Automation.PSCredential($Username, $Passwordsec)

################
################
# Specify the image

$Images = Get-AzureRmVMImage -Location $Location -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus $osSKU | Sort-Object -Descending -Property PublishedDate
#################
#Add Variables to the VM Config
$VM = New-AzureRmVMConfig -Name $VMName -VMSize $VMSize -AvailabilitySetId $availabilitySet.Id
$VM = Add-AzureRmVMNetworkInterface -VM $VM -Id $NIC.Id

################
################
#Specify the OS Disk

$StorAcct1 = Get-AzureRmStorageAccount -ResourceGroupName $RGStorage –StorageAccountName $StorAccNameOS 
$imageUri = $VHDStorageAccountURI
$OSDiskName = $VMName + "-c" 
$OSDiskUri = $StorAcct1.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName  + ".vhd"

################
################
# Set operating system and OS Disk variables

Set-AzureRmVMOperatingSystem -Windows -VM $VM -ProvisionVMAgent -EnableAutoUpdate -Credential $creds -ComputerName $VMName
Set-AzureRmVMOSDisk -VM $VM -Name $OSDiskName -VhdUri $OSDiskUri -Caching ReadWrite -CreateOption fromImage -SourceImageUri $imageUri -Windows
Set-AzureRmVMBootDiagnostics -VM $VM -Enable -ResourceGroupName $RGStorage -StorageAccountName $saaccountbootdiag

################
################
#Create Azure VM

New-AzureRmVM -ResourceGroupName $RGCompute -Location $location -VM $VM -Verbose
Remove-AzureRmVMExtension -Name BGInfo -ResourceGroupName $RGCompute -VMName $VM -Force



###### Script to set the AzureVM Custom Script Extension ######

$StorageAccountName = 'salrshrmweuprddiag'
$ContainerName = 'scripts'
$StorageKey = 'fjPbvlJtgbErKjIk/9Ztg42W1zyPiJ8HItt8T+CDok2mwjb1AxeWC05gycCIIvz4la3FPoxG2Sryh197qrQK3g=='

# Identify the target VM:
#
$ResourceGroup = "RG-WEU-PRD-HRM-RDS"
$Location = "westeurope"

Set-AzureRmVMCustomScriptExtension -ResourceGroupName $ResourceGroup -VMName $VMName -Name "CustomScriptExtension" -TypeHandlerVersion "1.4" -StorageAccountName $StorageAccountName -ContainerName $ContainerName -StorageAccountKey $StorageKey -Location $Location -FileName "15._JoinRDShostToTheDomain.ps1" -Run "15._JoinRDShostToTheDomain.ps1"
Remove-AzureRmVMExtension -Name BGInfo -ResourceGroupName $ResourceGroup -VMName $VMName -force

###### End of Script to set the AzureVM Custom Script Extension ######

#########################
#### End of RDSH 01 #####
#########################
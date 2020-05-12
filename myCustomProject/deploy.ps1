Connect-AzAccount

New-AzResourceGroup -Name "TestRG" -Location "West Europe"

$location = ".\myCustomProject\deployARM.json"
New-AzResourceGroupDeployment -Name TestTemplateDeploy -ResourceGroupName TestRG -TemplateFile $location 
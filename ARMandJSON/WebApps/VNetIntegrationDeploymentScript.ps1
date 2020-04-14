# Along with the VNetIntegrationWebApp.json template, this PowerShell script shows you how you can use ARM
# to enable VNet Integration for a Web App.

$SubscriptionId = "a1234567-8901-234b-56c7-d89e0f12a345"
$resourceGroupName = "myResourceGroup"
$vpnGatewayName = "myVpnGateway"
$webSiteName = "mySiteName"
$vnetName = "myVnetName"
$templateFile = "C:\myFile\VNetIntegrationWebApp.json"

Select-AzSubscription -Subscription $SubscriptionId

$packageUri = (Get-AzVpnClientPackage -ResourceGroupName $resourceGroupName -VirtualNetworkGatewayName $vpnGatewayName -ProcessorArchitecture Amd64) -replace '"',''
$publicCertData = (Get-AzVpnClientRootCertificate -VirtualNetworkGatewayName $vpnGatewayName -ResourceGroupName $resourceGroupName).PublicCertData
$params = @{
    Name = "VNetIntegration"
    ResourceGroupName = $resourceGroupName
    TemplateFile = $templateFile
    vpnPackageUri = $packageUri
    publicCertData = $publicCertData
    webSiteResourceName = $webSiteName
    vnetResourceName = $vnetName
}
New-AzResourceGroupDeployment @params

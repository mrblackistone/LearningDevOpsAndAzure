param (
    $AzureADGroupName,
    $ServicePrincipalName
)

Connect-AzureAD #-AzureEnvironmentName AzureUSGovernment
$aadGroup = Get-AzureAdGroup -SearchString $AzureADGroupName
$spn = Get-AzureAdServicePrincipal -SearchString $ServicePrincipalName
Add-AzureAdGroupMember -ObjectId $aadGroup.ObjectId -RefObjectId $spn.ObjectId
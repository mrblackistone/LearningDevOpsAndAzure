#The purpose of this script is to go through all of the resources you have access to across all
# of your Azure environment's subscriptions, and provide the two most recent available API versions
# for their respective provider namespaces and resource types.
# This will only grab APIs from resource providers which are registered in your current subscription.
function Get-AzureResourceAPIVersions {
    param (
        [Alias("InCurrentTenant")][Switch]$InUse,
        [Switch]$AllVersions
    )
    $a = @()
    if ($InUse) {
        Get-AzureRMsubscription | ForEach-Object {
            Select-AzureRMSubscription -Subscription $_.SubscriptionId
            Get-AzureRMResource | ForEach-Object {
                [string]$resourceType = $_.ResourceType
                if ($resourceType -notin $a) {$a += $resourceType}
            }
        }

        $a | ForEach-Object {
            $providerNamespace = $_.split("/", 2)[0]
            $resourceTypeName = $_.split("/", 2)[1]
            Write-Host $_":";
            ((Get-AzureRMResourceProvider -ProviderNamespace $providerNamespace).ResourceTypes | Where-Object ResourceTypeName -eq $resourceTypeName).ApiVersions[0, 1]; "";
        }
    } else {
        $a = @()
        $resourceProviders = Get-AzureRMResourceProvider
        foreach ($resourceProvider in $resourceProviders) {
            ($resourceProvider).ResourceTypes | ForEach-Object {
                $nameValue = $resourceProvider.ProviderNamespace+"/"+$_.ResourceTypeName
                $apiVersions = $_.ApiVersions
                if ($AllVersions) {
                    $a += @("$($nameValue): $($apiVersions)")
                } else {
                    $a += @("$($nameValue): $($apiVersions[0,1])")
                }
            }
        }
        Write-Output $a | Sort-Object
    }

}
Get-AzureResourceAPIVersions

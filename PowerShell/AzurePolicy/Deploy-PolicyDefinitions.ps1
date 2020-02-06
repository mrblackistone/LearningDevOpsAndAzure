#Requires -Modules az

<#
.SYNOPSIS
    Takes one or more policy definition files in a folder and deploys them to a single management group or subscription.
.DESCRIPTION
    Takes one or all policy definition files in a folder and its sub-folders, then deploys them to
    a single management group or subscription.
.PARAMETER Path
    Path to either a single Policy Definition file, or to the root folder containing all Policy Definition files
    to be deployed to the Management Group/Tenant Root or Subscription.
.PARAMETER ManagementGroup
    Also invoked as "TenantId".  This is the root tenant ID or the name of the Management Group where the
    Policy Definition will reside.
.PARAMETER SubscriptionId
    Subscription Id of the subscription where the Policy Definition will reside.
.PARAMETER Force
    Forces update/replacement of the Policy Definition objects, even if their display names do not match the
    referenced definition files.
.EXAMPLE
    Deploy-PolicyDefinitions.ps1 -Path "C:\DefinitionFiles" -ManagementGroup "Customer Subscriptions" -Force

    Deploys all Definition files found in the specified folder to the Management Group named "Customer Subscriptions",
    and forces the deployment to occur even if the display names of existing definitions don't match the ones found
    in the definition files.
.EXAMPLE
    Deploy-PolicyDefinitions.ps1 -Path "C:\DefinitionFiles\NSGPolicy.json" -TenantId "c3456789-0123-456d-78e9-f01a2b34c567"

    Deploys a single definition file "NSGPolicy.json" to the root tenant level.
.EXAMPLE
    Deploy-PolicyDefinitions.ps1 -Path "C:\DefinitionFiles" -SubscriptionId "b2345678-9012-345c-67d8-e90f1a23b456"

    Deploys all Definition files found in the specified folder to the given Subscription.
.NOTES
Author: Michael Blackistone
Date: January 31, 2020
#>

[CmdletBinding(DefaultParametersetName = "ManagementGroup")]
param (
    [Parameter(
        HelpMessage = "Path to the JSON file or folder containing the JSON files containing Azure Policy Definitions to be deployed, including all sub-folders.",
        Position = 1
    )]
    [ValidateScript( { Test-Path $_ })]
    [String]
    $Path,

    [Parameter(
        ParameterSetName = "ManagementGroup"
    )]
    [Alias("TenantId")]
    $ManagementGroup,

    [Parameter(
        ParameterSetName = "Subscription"
    )]
    [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
    $SubscriptionId,


    [Switch]$Force = $false
)

if ($ManagementGroup) {
    try { Get-AzManagementGroup -GroupName $ManagementGroup -ErrorAction "Stop" }
    catch [Microsoft.Azure.Commands.Resources.ManagementGroups.GetAzureRmManagementGroup] { "Provided management group name is invalid.  Exiting..." }
    catch { "An unspecified error has occurred.  Exiting." }
}

$policyDefinitionFiles = Get-ChildItem -Path $path -Recurse -Include "*.json"

# Example IDs of different types of policy definitions:
# Built-in:                 /providers/Microsoft.Authorization/policyDefinitions/a1234567-8901-234b-56c7-d89e0f12a345
# Custom/Subscription:      /subscriptions/a1234567-8901-234b-56c7-d89e0f12a345/providers/Microsoft.Authorization/policyDefinitions/PolicyDefinitionName
# Custom/Tenant:            /providers/Microsoft.Management/managementGroups/a1234567-8901-234b-56c7-d89e0f12a345/providers/Microsoft.Authorization/policyDefinitions/a1234567-8901-234b-56c7-d89e0f12a345
# Custom/Management Group:  /providers/Microsoft.Management/managementGroups/ManagementGroupName/providers/Microsoft.Authorization/policyDefinitions/a1234567-8901-234b-56c7-d89e0f12a345

foreach ($policyDefinitionFile in $policyDefinitionFiles) {
    
    # Convert the definition file to JSON
    $sourceDefinition = Get-Content $policyDefinitionFile.FullName | ConvertFrom-Json
    Write-Output "`r`nObtaining information from file `"$($policyDefinitionFile.FullName)`""
    
    # Check if the file is a valid Policy Definition and skip to the next if it is not
    if (($sourceDefinition.type -ne "Microsoft.Authorization/policyDefinitions")) {
        Write-Warning "File `"$($policyDefinitionFile.Name)`" is not a valid Policy Definition file.  Skipping"
        Continue
    }
    if (!($sourceDefinition.id -and $sourceDefinition.type -and $sourceDefinition.name -and $sourceDefinition.properties.policyRule -and $sourceDefinition.properties.displayName)) {
        Write-Warning "File `"$($policyDefinitionFile.Name)`" is not a valid Policy Definition file.  Skipping"
        Continue
    }


    $policyDefinitionName = $sourceDefinition.name
    $policyDefinitionDisplayName = $sourceDefinition.properties.displayName

    switch ($PSCmdlet.ParameterSetName) {
        "ManagementGroup" {
            $policyDefinition = Get-AzPolicyDefinition -Name $policyDefinitionName -ManagementGroupName $ManagementGroup -ErrorAction "SilentlyContinue"
        }
        "Subscription" {
            $policyDefinition = Get-AzPolicyDefinition -Name $policyDefinitionName -SubscriptionId $SubscriptionId -ErrorAction "SilentlyContinue"
        }
    }

    if ((!($policyDefinition)) -or ($policyDefinition.Name -eq $policyDefinitionName -and $policyDefinition.Properties.displayName -eq $policyDefinitionDisplayName) -or ($Force)) {
        $definitionParams = @{
            Name        = $policyDefinitionName
            DisplayName = $policyDefinitionDisplayName
            Policy      = $sourceDefinition.properties.policyRule | ConvertTo-Json -Depth 100
            Parameter   = $sourceDefinition.properties.parameters | ConvertTo-Json -Depth 100
            Mode        = $sourceDefinition.properties.mode
            Metadata    = "{'category':`'$($sourceDefinition.properties.metadata.category)`'}"
            Verbose     = $true
        }
        switch ($PSCmdlet.ParameterSetName) {
            "ManagementGroup" {
                $definitionParams += @{ ManagementGroupName = $ManagementGroup }
                New-AzPolicyDefinition @definitionParams
                Write-Output "Successfully deployed definition `"$policyDefinitionDisplayName`" to Management Group or Tenant `"$ManagementGroup`""        
            }
            "Subscription" {
                $definitionParams += @{ SubscriptionId = $SubscriptionId }
                New-AzPolicyDefinition @definitionParams
                Write-Output "Successfully deployed definition `"$policyDefinitionDisplayName`" to subscription `"$SubscriptionId`""        
            }
        }
    }
    else {
        Write-Warning "Conflict exists with an existing definition, where the Name and Display Name do not both match between the existing object and the definition file.  Review existing policy definition with name $policyDefinitionName in scope $scope and correct as necessary, or re-run this script with the -Force parameter to force the new definition to overwrite the existing definition. Skipping."
    }
}

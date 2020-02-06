#Requires -Modules az

<#
.SYNOPSIS
    Takes one or more policy assignment files in a folder and deploys them to a management group or subscription.
.DESCRIPTION
    Takes one or more policy assignment files in a folder and its sub-folders, then deploys them to
    a single management group or subscription.  Supports the assignment of definitions from other scopes.
    This script also detects invalid assignment files, and missing definitions, and skips assignment.
.PARAMETER Path
    Path to the root folder containing all of the policy assignment files to be applied.  Files must be in
    JSON format, as exported from the PowerShell command Get-AzPolicyAssignment.
.PARAMETER ManagementGroupName
    Can also be referred to by TenantId.  This is the Management group name or root Tenant Id where the
    assignment is being applied.
.PARAMETER SubscriptionId
    Subscription Id where the assignment is being applied.
.PARAMETER NotScopes
    Can also be referred to by ExcludedScopes parameter name.  Accepts an array of scopes as strings to be excluded
    from the effects of the assignment.  Format is one of the following:
    /subscriptions/subscriptionId
    /subscriptions/subscriptionId/resourceGroups/resourceGroupName
    /providers/Microsoft.Management/managementgroups/TenantIdOrManagementGroupName
.EXAMPLE 
    Deploy-PolicyAssignments.ps1 -Path "C:\MyPolicyAssignmentFiles" -TenantId "c3456789-0123-456d-78e9-f01a2b34c567" -NotScopes @("/providers/Microsoft.Management/managementgroups/ExcludedMgtGroup","/subscriptions/b2345678-9012-345c-67d8-e90f1a23b456")

    Deployment to root using Tenant Id and including exclusions to two different kinds of scopes
.EXAMPLE 
    Deploy-PolicyAssignments.ps1 -Path "C:\MyPolicyAssignmentFiles" -SubscriptionId "c3456789-0123-456d-78e9-f01a2b34c567" -ExcludedScopes @("/subscriptions/b2345678-9012-345c-67d8-e90f1a23b456/resourceGroups/excludedResourceGroup")

    Deployment to a subscription with a resource group exclusion and using the ExcludedScopes alias
.EXAMPLE 
    Deploy-PolicyAssignments.ps1 -Path "C:\MyPolicyAssignmentFiles" -ManagementGroup "My Management Group"

    Deployment to a Management Group
.NOTES
Author: Michael Blackistone
Date: January 31, 2020
#>

[CmdletBinding(DefaultParametersetName = "ManagementGroup")]
param (
    [Parameter(
        HelpMessage = "Path to the JSON file or folder containing the JSON files containing Azure Policy Assignments to be deployed, including all sub-folders.",
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

    [Alias("ExcludedScopes")]
    [String[]]$NotScopes,

    [Switch]$WhatIf
)

if ($ManagementGroup) {
    try { Get-AzManagementGroup -GroupName $ManagementGroup -ErrorAction Stop }
    catch { throw "Management Group specified does not exist.  Script cannot proceed.  Exiting." }
}

if ($WhatIf) { $WhatIfPreference = $true }

$policyAssignmentFiles = Get-ChildItem -Path $path -Recurse -Include "*.json"

# Example policy definition IDs:
# Built-in:                 /providers/Microsoft.Authorization/policyDefinitions/a1234567-8901-234b-56c7-d89e0f12a345
# Custom/Subscription:      /subscriptions/a1234567-8901-234b-56c7-d89e0f12a345/providers/Microsoft.Authorization/policyDefinitions/PolicyDefinitionName
# Custom/Tenant:            /providers/Microsoft.Management/managementGroups/a1234567-8901-234b-56c7-d89e0f12a345/providers/Microsoft.Authorization/policyDefinitions/a1234567-8901-234b-56c7-d89e0f12a345
# Custom/Management Group:  /providers/Microsoft.Management/managementGroups/ManagementGroupName/providers/Microsoft.Authorization/policyDefinitions/a1234567-8901-234b-56c7-d89e0f12a345

foreach ($policyAssignmentFile in $policyAssignmentFiles) {
    
    $scope = ""
    Remove-Variable -Name policyAssignment -ErrorAction "SilentlyContinue" -WhatIf:$false

    # Convert the Assignment file to JSON
    $assignmentObjectFromFile = Get-Content $policyAssignmentFile.FullName | ConvertFrom-Json -ErrorAction "Continue"
    Write-Output "`r`nObtaining information from file `"$($policyAssignmentFile.FullName)`""

    # Check if the file is a valid Policy Assignment and skip to the next if it is not
    if (!($assignmentObjectFromFile.PolicyAssignmentId)) {
        Write-Warning "File `"$($policyAssignmentFile.Name)`" is not a valid Policy Assignment file.  Skipping"
        Continue
    }

    # Set scope
    # If assignment is at Managment group level, set scope appropriately.
    if ($assignmentObjectFromFile.PolicyAssignmentId -match "^/providers/Microsoft.Management/managementgroups/") {
        switch ($PSCmdlet.ParameterSetName) {
            "ManagementGroup" {
                $scope = "/providers/Microsoft.Management/managementgroups/$($assignmentObjectFromFile.PolicyAssignmentId.Split("/")[4])"
                Write-Output "Scope set to `"/providers/Microsoft.Management/managementgroups/$($assignmentObjectFromFile.PolicyAssignmentId.Split("/")[4])`""
            }
            "Subscription" {
                Write-Warning "File `"$($policyAssignmentFile.Name)`" does not contain a policy assignment with a subscription scope.  Skipping"
                Continue
            }
        }
    }
    # If assignment file is at subscription level, set scope appropriately.
    elseif ($assignmentObjectFromFile.PolicyAssignmentId -match "^/subscriptions/") {
        switch ($PSCmdlet.ParameterSetName) {
            "Subscription" {
                $scope = "/subscriptions/$($assignmentObjectFromFile.PolicyAssignmentId.Split("/")[2])"
                Write-Output "Scope set to `"/subscriptions/$($assignmentObjectFromFile.PolicyAssignmentId.Split("/")[2])`""
            }
            "ManagementGroup" {
                Write-Warning "File `"$($policyAssignmentFile.Name)`" does not contain a policy assignment with a management group scope.  Skipping"
                Continue
            }
        }
    }
    # If file is missing the Policy Assignment Id, skip the file.
    else {
        Write-Warning "Policy assignment id in source template `"$($policyAssignmentFile.FullName)`" is invalid or missing. Skipping."
        Continue
    }

    $policyAssignmentNameFromFile = $assignmentObjectFromFile.Name
    $policyAssignmentDisplayNameFromFile = $assignmentObjectFromFile.Properties.displayName

    #Retrieve policy definition referenced in the policy assignment file.
    if ($assignmentObjectFromFile.Properties.policyDefinitionId -match "^/providers/Microsoft.Management/managementgroups/") {
        $policyDefinition = Get-AzPolicyDefinition -Name $assignmentObjectFromFile.Properties.policyDefinitionId.Split("/")[-1] -ManagementGroupName $assignmentObjectFromFile.Properties.policyDefinitionId.Split("/")[4] -ErrorAction "SilentlyContinue"
        if ($policyDefinition) { Write-Output "Policy definition $($assignmentObjectFromFile.Properties.policyDefinitionId.Split("/")[-1]) in management group $($assignmentObjectFromFile.Properties.policyDefinitionId.Split("/")[4]) found." }
        else { Write-Warning "Policy definition $($assignmentObjectFromFile.Properties.policyDefinitionId.Split("/")[-1]) in management group $($assignmentObjectFromFile.Properties.policyDefinitionId.Split("/")[4]) not found." }
    }
    elseif ($assignmentObjectFromFile.Properties.policyDefinitionId -match "^/subscriptions/") {
        $policyDefinition = Get-AzPolicyDefinition -Name $assignmentObjectFromFile.Properties.policyDefinitionId.Split("/")[-1] -SubscriptionId $assignmentObjectFromFile.Properties.policyDefinitionId.Split("/")[2] -ErrorAction "SilentlyContinue"
        if ($policyDefinition) { Write-Output "Policy definition $($assignmentObjectFromFile.Properties.policyDefinitionId.Split("/")[-1]) in management group $($assignmentObjectFromFile.Properties.policyDefinitionId.Split("/")[2]) found." }
        else { Write-Warning "Policy definition $($assignmentObjectFromFile.Properties.policyDefinitionId.Split("/")[-1]) in management group $($assignmentObjectFromFile.Properties.policyDefinitionId.Split("/")[2]) not found." }
    }
    elseif ($assignmentObjectFromFile.Properties.policyDefinitionId -match "^/providers/Microsoft.Authorization/policy") {
        switch ($PSCmdlet.ParameterSetName) {
            "ManagementGroup" {
                $policyDefinition = Get-AzPolicyDefinition -Name $assignmentObjectFromFile.Properties.policyDefinitionId.Split("/")[-1] -ManagementGroupName $ManagementGroup -Builtin -ErrorAction "SilentlyContinue"
                Write-Output "Built-in policy definition `"$($assignmentObjectFromFile.Properties.policyDefinitionId.Split("/")[-1])`" found while using management group `"$ManagementGroup`""
            }
            "Subscription" {
                $policyDefinition = Get-AzPolicyDefinition -Name $assignmentObjectFromFile.Properties.policyDefinitionId.Split("/")[-1] -SubscriptionId $SubscriptionId -Builtin -ErrorAction "SilentlyContinue"
                Write-Output "Built-in policy definition `"$($assignmentObjectFromFile.Properties.policyDefinitionId.Split("/")[-1])`" found while using subscription `"$SubscriptionId`""
            }
        }
    }
    else {
        Write-Warning "Invalid Policy Definition Id found in source assignment template `"$($policyAssignmentFile.FullName)`". Skipping."
        Continue
    }
            
    # Skip policy assignment if referenced definition does not exist.
    if (!($policyDefinition)) {
        Write-Warning "Policy Definition with name `"$($assignmentObjectFromFile.Properties.policyDefinitionId.Split("/")[-1])`" contained in policy assignment file `"$($policyAssignmentFile.Name)`" does not exist.  Skipping this policy assignment."
        Continue
    }

    # Get existing policy assignment object
    $policyAssignment = Get-AzPolicyAssignment -Name $assignmentObjectFromFile.Name -Scope $scope -ErrorAction "Continue"
    # Add error handling to line above.

    if (!($policyAssignment)) {
        Write-Warning "Policy Definition could not be found, assignment action skipped."
        Continue
    }
    elseif (($policyAssignment.Name -eq $policyAssignmentNameFromFile -and $policyAssignment.Properties.displayName -eq $policyAssignmentDisplayNameFromFile)) {
        
        # Convert parameter names and values from PSCustomObject, derived from the assignment file, to a hashtable for use in the New-AzPolicyAssignment command.
        $policyParameterObject = @{ }
        $assignmentObjectFromFile.Properties.parameters.psobject.Properties | ForEach-Object { $policyParameterObject[$_.Name] = $_.Value.value }
        
        # Prepare arguments for New-AzPolicyAssignment command.
        $assignmentParams = @{
            Name                  = $policyAssignmentNameFromFile
            Scope                 = $scope
            NotScope              = $notScopes
            DisplayName           = $policyAssignmentDisplayNameFromFile
            Description           = $assignmentObjectFromFile.Properties.description
            PolicyParameterObject = $policyParameterObject
            #PolicyParameter       = ""
            Metadata              = "{'category':`'$($assignmentObjectFromFile.Properties.metadata.category)`'}"
            #EnforcementMode       = ""
            #AssignIdentity        = ""
            #Location              = ""
            #ApiVersion            = ""
            #AssignIdentity        = $true
            Verbose               = $true
        }

        # Update params with PolicyDefinition or PolicySetDefinition parameter name, based on the type of referenced definition.
        if ($policyDefinition.ResourceId -match "/policyDefinitions/") {
            $assignmentParams += @{
                PolicyDefinition = $policyDefinition
            }
        }
        elseif ($policyDefinition.ResourceId -match "/policySetDefinitions/") {
            $assignmentParams += @{
                PolicySetDefinition = $policyDefinition
            }
        }
        else {
            Write-Warning "Referenced policy definition has an invalid ResourceId.  Skipping assignment."
            Continue
        }

        # Deploy or update policy assignment.
        if ($WhatIf) {
            Write-Output "What if: Performing the operation `"New`" on target `"Policy Assignment Name: $policyAssignmentNameFromFile`"."
        }
        else {
            Write-Output "Deploying policy assignment:"
            New-AzPolicyAssignment @assignmentParams
        }
    }
    elseif ($policyAssignment.Name -ne $policyAssignmentNameFromFile -or $policyAssignment.Properties.displayName -ne $policyAssignmentDisplayNameFromFile) {
        Write-Warning "This policy assignment definition does not match the existing assignment's name and display name.  Skipping."
        Continue
    }
    else {
        Write-Warning "Unspecified error encountered, skipping to next assignment definition file."
        Continue
    }
}
    


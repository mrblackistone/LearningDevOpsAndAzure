# First, ensure your ARM Deployment task in Azure DevOps is set to assign the output to the "ARMOutput" variable name.
# Then have this script run as the next task (inline PowerShell) to extract a specific value from that output
# This script then sets a new pipeline variable, set to this specific value
# The next task that requires the value simply has to reference the new variable name (ServicePlanResourceId in the example below)

$ARMOutput = @"
$(ARMOutput)
"@

$json = $ARMOutput | convertfrom-json

Write-Output -InputObject ($json.ServicePlanResourceId.value)

Write-Host "##vso[task.setvariable variable=ServicePlanResourceId;]$($json.ServicePlanResourceId.value)"

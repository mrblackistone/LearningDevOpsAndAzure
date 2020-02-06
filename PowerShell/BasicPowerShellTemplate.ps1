#Requires -Version <N>[.<n>]
#Requires -PSSnapin <PSSnapin-Name> [-Version <N>[.<n>]]
#Requires -Modules az, @{ ModuleName="AzureRM.Netcore"; ModuleVersion="0.12.0" }
#Requires -Modules az, @{ ModuleName="AzureRM.Netcore"; MaximumVersion="0.12.0" }
#Requires -Modules az, @{ ModuleName="AzureRM.Netcore"; RequiredVersion="0.12.0" }
#Requires -PSEdition Core <or Desktop>
#Requires -ShellId <ShellId>
#Requires –RunAsAdministrator

<#
.SYNOPSIS
    Brief description of the script.
.DESCRIPTION
    Detailed description of the script.
.PARAMETER param1
    Description of the "param1" parameter
.PARAMETER param2
    Description of the "param2" parameter
.EXAMPLE
    Example of how to run the script
.NOTES
Author: Michael Blackistone
Date: January 17, 2020
#>

# The requires statements above are used if the script has certain requirements.

# The comment block above provides information to the user of the script, such as what it's for, how it's used,
# what kind of information should be passed to the parameters, etc.

# The following attributes are available inside the param block.  With the exception of the "Parameter" attribute,
# they are also available outside of the param block:
[CmdletBinding(DefaultParametersetName="p1")]
param (
    [Switch]$switchName,
    [ValidateRange(60, 9999)]$intVariableMustBeBetween60And9999,
    [ValidateSet("High", "Medium", "Low")]$stringMustBeOneOfThreeValues,
    [ValidateScript( { Test-Path $_ -PathType 'Container' })]$thisScriptMustSucceedUsingThisVariablesValue,
    [Alias("CN", "MachineName")]$alternativeNamesForThisParameterWhenCallingThisScript,
    [AllowNull()]$valueMayBeNull,
    [AllowEmptyString()]$valueMayBeAnEmptyString,
    [AllowEmptyCollection()]$valueMayBeEmptyCollection,
    [ValidateCount(1, 5)]$numberOfObjectInCollectionMustBeBetween1And5,
    [ValidateLength(1, 15)]$lengthOfStringMustBeBetween1And15,
    [ValidatePattern("regexHere")]$valueMustMatchRegEx,
    [ValidateNotNull()]$valueMustNotBeNull,
    [ValidateNotNullOrEmpty()]$valueMustNotBeNullOrEmpty,
    [Parameter(Mandatory = $true, HelpMessage = "Message", DontShow = $true, ParameterSetName = "p1", Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $false)]$thisParameterUsesSpecialProcessingAsShown
)

#------------------------------------------------------------------------------
#
# Copyright © 2019 Microsoft Corporation.  All rights reserved.
#
# THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED "AS IS" WITHOUT
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS
# FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR
# RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
#
#------------------------------------------------------------------------------


if ((Get-AzContext).count -eq 0) { Connect-AzAccount -Environment azureusgovernment }
if (!(Get-AzContext).Subscription) { (Get-AzSubscription)[0] | Select-AzSubscription }

try { feiwowjfwo }
catch {
    "An error occurred!"
    $_.ScriptStackTrace
    $_.Exception
    $_.ErrorDetails
}

switch ($PsCmdlet.ParameterSetName)
    {
    "p1"  { Write-Host "Set p1"; break}
    "p2"  { Write-Host "Set p2"; break}
    }

Write-Output "Execution goes here!"

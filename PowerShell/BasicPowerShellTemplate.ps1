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
Date: February 13, 2020
#>

# The requires statements above are used if the script has certain requirements.

# The comment block above provides information to the user of the script, such as what it's for, how it's used,
# what kind of information should be passed to the parameters, etc.

# The following attributes are available inside the param block.  With the exception of the "Parameter" attribute,
# they are also available outside of the param block:
[CmdletBinding(DefaultParametersetName = "p1")]
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

# Example disclaimer:

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

# Example commands to log into Azure Government and select a subscription if not already logged in:
if ((Get-AzContext).count -eq 0) { Connect-AzAccount -Environment azureusgovernment }
if (!(Get-AzContext).Subscription) { (Get-AzSubscription)[0] | Select-AzSubscription }

# Example try;catch;finally block:
try { SomethingThatMightThrowABreakingException }
catch [System.Net.WebException],[System.IO.IOException] {
    "A web error occurred!"
    $_.ScriptStackTrace
    $_.Exception
    $_.ErrorDetails
}
catch { "An unknown error occurred" }
finally { "Put code here that should run regardless of whether the try succeeded or not" }

Example switch statement:
switch ($PsCmdlet.ParameterSetName) {
    "p1" { Write-Host "Set p1"; break }
    "p2" { Write-Host "Set p2"; break }
}

#Example text outputs
Write-Output "Execution goes here!"
Write-Warning "This is a warning!"
Write-Error "This is an error."
Write-Host "This goes to the current interactive terminal."
Set-Content # Create or overwrite a file's contents.
Add-Content # Add to a file's contents.

# Change defaults for how commands are processed, such as error handling and confirmation:
$ErrorActionPreference = "Continue"
$ConfirmPreference = $true

# PowerShell default variables exist.  Here are a few:
$PSVersionTable
$PSCulture
$PSEdition

# Retrieve errors:
$error               #All errors from session
$error[0]            #Most recent error
$error[-1]           #First error
$error[0].Exception  #Most recent error's exception message

# Environment variables are useful. Use tab-completion to see what's available.  One example:
$env:ALLUSERSPROFILE

# Conditional logic based on what parameter set is in use:
if ($PsCmdlet.ParameterSetName -eq "ParameterSet1") {Do-This} else {Do-ThisOtherThing}

workflow Test-Workflow {
    [CmdletBinding(ConfirmImpact = "string",
        DefaultParameterSetName = "string",
        HelpURI = "URI",
        PositionalBinding = "boolean")]

    Param (
        [parameter(Mandatory = $true)]
        [String[]]
        $param1
    )

    Foreach -Parallel -ThrottleLimit 50 ($member in $collection) {
        #Do things which don't conflict with each other. Don't manipulate the same object(s) in parallel threads.
    }
}
Test-Workflow -param1 @("string1", "string2")

Function Test-Function {
    param (
        $param1
    )
    Write-Output $param1
}
Test-Function -param1 "Output"
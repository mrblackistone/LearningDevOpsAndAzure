<#
.SYNOPSIS
    Generates two lists of available VM SKU sizes from one or more Azure regions.
.DESCRIPTION
    Generates two lists of available VM SKU sizes, one for use in an ARM template array, and the other for
    use in a PowerShell array.  One, several, or all regions can be specified.  This script is written for
    Azure U.S. Government regions, but can easily be modified for use with Azure Commercial regions.
.PARAMETER AllRegions
    If specified (or if no parameters are provided), all regions will be assessed.
.PARAMETER Regions
    Array containing the names of one or more regions to assess.
.EXAMPLE
    Get-VMSKUSizes -AllRegions
.EXAMPLE
    Get-VMSKUSizes -AllDatacenters
.EXAMPLE
    $regions = @("usgovvirginia","usgovtexas")
    Get-VMSKUSizes -Regions $regions
.NOTES
Author: Michael Blackistone
Date: February 5, 2020
#>

[CmdletBinding(DefaultParameterSetName="AllRegions")]
param (
    [parameter(ParameterSetName = "AllRegions")]
    [Alias("AllDatacenters")]
    [Boolean]
    $AllRegions = $true,

    [parameter(ParameterSetName = "SpecificRegions")]
    [ValidateSet("usgovvirginia", "usgoviowa", "usgovtexas", "usgovarizona")]
    [Array]
    $Regions
)

$finalSizeList = @()

if ($allRegions) {
    $regions = @(
        "usgovvirginia",
        "usgoviowa",
        "usgovtexas",
        "usgovarizona"
    ) 
}

foreach ($region in $regions) {
    $sizes = (Get-AzVMSize -Location $region).Name
    foreach ($size in $sizes) {
        if ($size -notin $finalSizeList) {$finalSizeList += $size}
    }
}

$listString = "`""
$count = 0
[string[]]$skuSizeList = @()
Write-Output "`nList for use in ARM template:"
foreach ($finalSize in $finalSizeList) {
    $count++
    $listString += $finalSize
    if ($count -ne $finalSizeList.count) {
        $listString += "`",`""
        [String]$a = "`"" + $finalSize + "`","
    }
    else {
        $listString += "`""
        [String]$a = "`"" + $finalSize + "`""
    }
    $skuSizeList += $a
}
Write-Output $skuSizeList

Write-Output "`nString for use in PowerShell script:"
Write-Output $listString
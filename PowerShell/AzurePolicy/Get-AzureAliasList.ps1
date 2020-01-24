param (
    [parameter(HelpMessage="Used to send the results to a txt file.")]
    [String]$FilePath
)

#Test for valid path
$split = $path.Split("\")
if (!(Test-Path (($split[0..($split.Count - 2)] -join "\")))) {
    throw "File path does not exist.  Exiting."
}
#Test for valid filename
if ($path -match '\\$' -or $path -match '\\.$') {Throw "No file name provided. Exiting."}
#Test for valid extension and add it if missing
if ($path -notmatch '.txt$' -and $path -match '[\w ]+$') {$path += ".txt"}

$responses = Get-AzPolicyAlias -ListAvailable
$aliases = [System.Collections.Generic.List[PSCustomObject]]::new()

foreach ($response in $responses) {
    if ($response.Aliases) {
        foreach ($obj in $response.Aliases) {
            $alias = [PSCustomObject]@{
                Namespace = $response.Namespace
                resourceType = $response.resourceType
                alias = $obj.Name
            }
            $aliases.Add($alias)
        }
    }
}

# Output the list and sort it by Namespace, resourceType and alias. You can customize with Where-Object to limit as desired.
if ($FilePath) {
        $aliases | Sort-Object -Property Namespace, resourceType, alias | Format-Table | Out-String -Width 4096| out-file $FilePath
        Write-Output "Alias list saved to file $FilePath"
} else {
    return $aliases | Sort-Object -Property Namespace, resourceType, alias
}
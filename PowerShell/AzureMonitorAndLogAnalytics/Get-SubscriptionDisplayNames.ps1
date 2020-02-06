# This subscription generates a Log Analytics query to be used to create a lookup table that
# maps SubscriptionIds to their Display Names.  Simply run the output in Log Analytics and
# then save the query as a Function to your Log Analytics workspace.

$subscriptions = Get-AzSubscription

$output = @()
foreach ($subscription in $subscriptions) {
    $output += [PSCustomObject]@{
        Id = $subscription.Id
        Name = $subscription.Name
    }
}
$Csv = $output | ConvertTo-Csv
#$Csv = $Csv[2..($Csv.Length-1)] #Eliminate the first two unnecessary rows containing type and header information
$Csv = $Csv | ForEach-Object { $_ + "," }
#$Csv = $Csv -replace "`"", "`'"
$Csv[-1] = $Csv[-1] -replace '",', '"'
$Csv[-1] = $Csv[-1] -replace '""', '","'
$Csv[0] = "//Create a lookup table to resolve Azure Subscription Names to Display Names"
$Csv[1] = "let SubscriptionLookupTable=datatable(SubscriptionId:string, SubscriptionDisplayName:string)["
$Csv += "];","SubscriptionLookupTable"

$Csv | Out-File c:\temp\SubscriptionLookupTable-Query.txt #For recording purposes, if desired
& Notepad c:\temp\SubscriptionLookupTable-Query.txt #For review purposes, if desired

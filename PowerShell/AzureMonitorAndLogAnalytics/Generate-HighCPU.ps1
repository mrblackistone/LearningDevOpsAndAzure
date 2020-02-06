# Run on a VM to generate high CPU for testing metrics/alerts in Azure Monitor

$endtime = (get-date).AddMinutes(15)
Write-host 'Script generates high CPU load and will be stopped at ' $endtime 
$result = 1 
foreach ($number in 1..750000000) {
    $result = $result * $number
    if ($endtime -lt (get-date)) { break } 
}
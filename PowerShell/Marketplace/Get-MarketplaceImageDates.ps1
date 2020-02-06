param (
    $Region = "usgovvirginia", #This region is in the U.S. Government Azure cloud and should be changed to your region.
    $PublisherName = "MicrosoftWindowsServer",
    $OfferName = "WindowsServer",
    $SkuName = "2016-Datacenter"
)

<#
# Manual steps to get the information you would pass into the parameters,
# if you're looking for a differnt publisher, offer, or sku than is included in the example:
$region="eastus"
Get-AzVMImagePublisher -Location $region | Select PublisherName
# ...then...
$pubName="MicrosoftWindowsServer"
Get-AzVMImageOffer -Location $region -PublisherName $pubName | Select Offer
# ...then...
$offerName="WindowsServer"
Get-AzVMImageSku -Location $region -PublisherName $pubName -Offer $offerName | Select Skus
# ...then...
$skuName="2016-Datacenter"
$images = Get-AzVMImage -Location $region -PublisherName $pubName -Offer $offerName -Sku $skuName
$images | Select-Object Version
$version="14393.3443.2001090113"
Get-AzVMImage -Location $region -PublisherName $pubName -Offer $offerName -Skus $skuName -Version $version
#>

$images = Get-AzVMImage -Location $region -PublisherName $publisherName -Offer $offerName -Sku $skuName
foreach ($image in $images) {
    if ($image.Version -match "^\d{5}.\d{4}.\d{10}$") {
        $image.Version
        $stringDateTime = "20$($image.Version.split('.')[2])"
        $dateTime = [Datetime]::ParseExact($stringDateTime, 'yyyyMMddHHmm', $null)
    } elseif ($image.Version -match "^\d{5}.\d{4}.\d{8}$") {
        $image.Version
        $stringDateTime = $($image.Version.split('.')[2])
        $stringDateTime = $stringDateTime.PadRight(12,'0')
        $dateTime = [Datetime]::ParseExact($stringDateTime, 'yyyyMMddHHmm', $null)
    } elseif ($image.Version -match "^\d{4}.\d{1,3}.\d{8}$") {
        $image.Version
        $stringDateTime = $($image.Version.split('.')[2])
        $stringDateTime = $stringDateTime.PadRight(12,'0')
        $dateTime = [Datetime]::ParseExact($stringDateTime, 'yyyyMMddHHmm', $null)
    } else {
        $dateTime = [Datetime]::ParseExact('190001010000', 'yyyyMMddHHmm', $null)
    }
    Add-Member -InputObject $image -MemberType NoteProperty -Name VersionDate -Value $dateTime
}
$images | Select-Object Version,VersionDate | Sort-Object -Property VersionDate
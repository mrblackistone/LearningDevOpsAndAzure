function Get-StringHash
{
<#
       .SYNOPSIS
             Get the hash value for a string.
       
       .DESCRIPTION
             Get the hash value for a string.
       
       .PARAMETER String
             The string to hash.
       
       .PARAMETER Algorithm
             The algorithm to use for hashing.
             Defaults to SHA512
       
       .EXAMPLE
             PS C:\> Get-StringHash -String $text
       
             Returns the hash value for the string provided in $text
#>
       [CmdletBinding()]
       param (
             [Parameter(ValueFromPipeline = $true)]
             [string[]]
             $String,
             
             [ValidateSet('SHA1', 'MD5', 'SHA256', 'SHA384', 'SHA512')]
             [string]
             $Algorithm = 'SHA512'
       )
       
       begin
       {
             $hashAlgorithm = [System.Security.Cryptography.HashAlgorithm]::Create($Algorithm)
       }
       process
       {
             foreach ($entry in $String)
             {
                    $stringBuilder = New-Object System.Text.StringBuilder
                    foreach ($byte in $hashAlgorithm.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($entry)))
                    {
                           [Void]$StringBuilder.Append($byte.ToString("x2"))
                    }
                    $StringBuilder.ToString()
             }
       }
}

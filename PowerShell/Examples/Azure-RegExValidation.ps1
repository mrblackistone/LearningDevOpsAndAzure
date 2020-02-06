#Availability Set Name
#Rules:  1-80 characters, starting with letter or number, ending with letter number or underscore, and containing all of these plus periods and hyphens.
[ValidatePattern("^([a-zA-Z0-9]|[a-zA-Z0-9][\w.-]{0,78}\w)$")]

#CIDR-notated IPv4 Address Range
#(0.0.0.0/1 through 255.255.255.255/32)
[ValidatePattern("^(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])){3}/(3[0-2]|[1-2][0-9]|[1-9])$")]

#IPv4 Address
#(0.0.0.0 through 255.255.255.255)
[ValidatePattern("^(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]{1})(\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]{1})){3}$")]

#Key Vault Name
#Rules:  3-24, alphanumeric and dashes, cannot start with number, begin with letter, end with letter or digit, no consecutive hyphens.
[ValidatePattern("^[a-zA-Z]((-[a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9]?){1,11}|(-[a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9]?){1,10}[a-zA-Z0-9]?-?)[a-zA-Z0-9]$")]

#Key Vault URL (Azure Government Only)
#Rules:  https://validkeyvaultname.vault.usgovcloudapi.net/
[ValidatePattern("^https://[a-zA-Z]((-[a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9]?){1,11}|(-[a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9]?){1,10}[a-zA-Z0-9]?-?)[a-zA-Z0-9]\.vault\.usgovcloudapi\.net/$")]

#Key Vault URL (Azure Commercial Only)
#Rules:  https://validkeyvaultname.vault.azure.net/
[ValidatePattern("^https://[a-zA-Z]((-[a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9]?){1,11}|(-[a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9]?){1,10}[a-zA-Z0-9]?-?)[a-zA-Z0-9]\.vault\.azure\.net/$")]

#Key Vault Resource ID (Azure Government Only)
#Rules:  /subscriptions/01234567-89ab-cdef-4444-555555555555/resourceGroups/rgName/providers/Microsoft.KeyVault/vaults/validVaultName
[ValidatePattern("^/subscriptions/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/resourceGroups/[\w.()-]{0,89}[\w()-]/providers/Microsoft.KeyVault/vaults/[a-zA-Z]((-[a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9]?){1,11}|(-[a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9]?){1,10}[a-zA-Z0-9]?-?)[a-zA-Z0-9]$")]

#Location (Azure Government)
#Rules:  N/A
[ValidateSet("usgovvirginia","usgoviowa","usgovtexas","usgovarizona")]

#NSG Name
#Rules:  1-80 characters, starting with letter or number, ending with letter number or underscore, and containing all of these plus periods and hyphens.
[ValidatePattern("^([a-zA-Z0-9]|[a-zA-Z0-9][\w.-]{0,78}\w)$")]
#Note: First part of Or statement "|" required to allow for single-character name.  Second part allows for 2-80 characters.

#Resource Group Name
#Rules:  1-90 characters, Alphanumeric, underscore, period, parenthesis, and hyphen.  Can't end in period.
[ValidatePattern("^[\w.()-]{0,89}[\w()-]$")]

#Subnet Name
#Rules:  1-80 characters, beginning with a letter or number, ending a with letter, number, or underscore, and containing any of these plus periods and hyphens.
[ValidatePattern("^([a-zA-Z0-9]|[a-zA-Z0-9][\w.-]{0,78}\w)$")]
#Note: First part of Or statement "|" required to allow for single-character name.  Second part allows for 2-80 characters.

#Subscription ID
#Rules:  Hyphen-separated groups of lower-case hexadecimal characters in the pattern 8-4-4-4-12
[ValidatePattern("^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$", Options = 'None')]

#Virtual Machine Name
#Rules:  1-15 characters, begin and end with letter or number, can also contain hyphens.
[ValidatePattern("^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]{0,13}[a-zA-Z0-9])$")]

#Virtual Network Name
#Rules:  2-64 characters, starting with a letter or number, ending with a letter, number, or underscore, and containing any of these plus periods and hyphens.
[ValidatePattern("^[a-zA-Z0-9][\w.-]{0,62}\w$")]

$foo
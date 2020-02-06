function Get-Constructors ([type]$type)
{
    foreach ($constr in $type.GetConstructors())
    {
        $params = ''
        foreach ($parameter in $constr.GetParameters())
        {
            if ($params -eq '') {
                $params =  "{0} {1}" -f $parameter.parametertype.fullname,
                    $parameter.name
            } else {
              $params +=  ", {0} {1}" -f $parameter.parametertype.fullname,
                  $parameter.name
            }
        }
        Write-Host $($constr.DeclaringType.Name) "($params)"
    }
}
Get-Constructors "System.String"

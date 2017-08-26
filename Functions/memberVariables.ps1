function Get-MemberProperties
{
    param
    (
        [Parameter(ValueFromPipeline = $true,
                   Mandatory = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo
    )
    process
    {
        return $TypeInfo.GetMembers() | 
            ? { $_.MemberType -eq 'Property' }
    }
}

function Test-DscProperty
{
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   Position = 1)]
        [System.Reflection.PropertyInfo]
        $PropertyInfo
    )
    process
    {
        [bool] ( $PropertyInfo.CustomAttributes |
            ? { $_.AttributeType.Name -eq 'DscPropertyAttribute' } )
    }
}

function Assert-DscProperties
{
    param
    (
        [Parameter(ValueFromPipeline = $true,
                   Mandatory = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo
    )
    process
    {
        if ( $TypeInfo | 
            Get-MemberProperties | 
            Test-DscProperty |
            ? { $_ }
        )
        {
            return
        }
        throw "DSC properties not found for type $TypeInfo."
    }
}
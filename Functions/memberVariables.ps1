function Get-MemberProperty
{
    param
    (
        [Parameter(Position = 1)]
        [string]
        $Filter = '*',

        [Parameter(ValueFromPipeline = $true,
                   Mandatory = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo
    )
    process
    {
        return $TypeInfo.GetMembers() | 
            ? { $_.MemberType -eq 'Property' } |
            ? { $_.Name -like $Filter }
    }
}

function Test-MemberProperty
{
    param
    (
        [Parameter(Position = 1,
                   Mandatory = $true)]
        [string]
        $PropertyName,

        [Parameter(ValueFromPipeline = $true,
                   Mandatory = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo    
    )
    process
    {
        [bool]($TypeInfo | Get-MemberProperty $PropertyName)
    }
}

function Assert-MemberProperty
{
    param
    (
        [Parameter(ParameterSetName = 'affirmative',
                   Position = 1,
                   Mandatory = $true)]
        [string]
        $PropertyName,

        [Parameter(ParameterSetName = 'negative')]
        [string]
        $Not,

        [Parameter(ValueFromPipeline = $true,
                   Mandatory = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo    
    )
    process
    {
        $_propertyName = $PropertyName,$Not | ? {$_}
        if
        ( 
            ( $TypeInfo | Test-MemberProperty $_propertyName ) -xor
            ( $PSCmdlet.ParameterSetName -eq 'negative' )
        )
        {
            return
        }
        
        if ( $PSCmdlet.ParameterSetName -eq 'affirmative' )
        {
            throw "Property $_propertyName not found on type $($TypeInfo.Name)."
        }
        throw "Property $_propertyName found on type $($TypeInfo.Name)."
    }
}

function Get-PropertyCustomAttribute
{
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [string]
        $AttributeName,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Reflection.PropertyInfo]
        $PropertyInfo
    )
    process
    {
        $PropertyInfo.CustomAttributes |
            ? {$_.AttributeType.Name -eq "$AttributeName`Attribute" }
    }
}

function Test-PropertyCustomAttribute
{
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [string]
        $AttributeName,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Reflection.PropertyInfo]
        $PropertyInfo
    )
    process
    {
        [bool](Get-PropertyCustomAttribute @PSBoundParameters)
    }
}

function Assert-PropertyCustomAttribute
{
    param
    (
        [Parameter(ParameterSetName = 'affirmative',
                   Mandatory = $true,
                   Position = 1)]
        [string]
        $AttributeName,

        [Parameter(ParameterSetName = 'negative')]
        [string]
        $Not,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Reflection.PropertyInfo]
        $PropertyInfo
    )
    process
    {
        $_attributeName = $AttributeName,$Not | ? {$_}
        if
        ( 
            ( $PropertyInfo | Test-PropertyCustomAttribute $_attributeName ) -xor
            ( $PSCmdlet.ParameterSetName -eq 'negative' )
        )
        {
            return
        }

        if ( $PSCmdlet.ParameterSetName -eq 'negative' )
        {
            throw "Custom attribute $AttributeName exists on $($PropertyInfo.Name)."
        }

        throw "Custom attribute $AttributeName does not exist on $($PropertyInfo.Name)."
    }
}

function Get-CustomAttributeArgument
{
    param
    (
        [Parameter(Position = 1)]
        [string]
        $ArgumentName,

        [switch]
        $ValueOnly,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [System.Reflection.CustomAttributeData]
        $CustomAttributeData
    )
    process
    {
        $object = $CustomAttributeData.NamedArguments |
            ? {$_.MemberName -eq $ArgumentName}

        if ( $ValueOnly )
        {
            return $object.TypedValue.Value
        }
        return $object
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

function Assert-HasDscProperty
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
            Get-MemberProperty | 
            Test-DscProperty |
            ? { $_ }
        )
        {
            return
        }
        throw "DSC properties not found for type $TypeInfo."
    }
}

function Assert-DscProperty
{
    param
    (
        [Parameter(Position = 1)]
        [string]
        $Filter = '*',

        [Parameter(ValueFromPipeline = $true,
                   Mandatory = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo
    )
    process
    {
        $TypeInfo |
            Get-MemberProperty $Filter |
            ? { -not ($_ | Test-DscProperty) } |
            % { 
                throw "[DscProperty()] attribute not found for member $($_.Name) of $TypeInfo."
            }
    }
}

function Get-PropertyType
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
        $PropertyInfo.PropertyType
    }
}

function Get-PropertyDefault
{
    param
    (
        [Parameter(Position = 1,
                   Mandatory = $true)]
        [string]
        $PropertyName,

        [Parameter(ValueFromPipeline = $true,
                   Mandatory = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo
    )
    process
    {
        $TypeInfo.DeclaredConstructors[0].Invoke($null).$PropertyName
    }
}

function Assert-PropertyDefault
{
    param
    (
        [Parameter(Position = 1,
                   Mandatory = $true)]
        [string]
        $PropertyName,

        [Parameter(Position = 2,
                   Mandatory = $true)]
        [AllowNull()]
        $Value,

        [Parameter(ValueFromPipeline = $true,
                   Mandatory = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo
    )
    process
    {
        if ( -not ($TypeInfo | Get-MemberProperty $PropertyName) )
        {
            return
        }

        $actualValue = $TypeInfo | Get-PropertyDefault $PropertyName
        if ( $actualValue -eq $Value )
        {
            return
        }

        $printValue = $Value
        if ( $null -eq $Value ) { $printValue = '$null' }

        throw "Default value $actualValue does not match expected value $printValue for property $PropertyName of [$TypeInfo]."
    }
}

function Assert-NullDscPropertyDefaults
{
    param
    (
        [string[]]
        $Exclude,

        [Parameter(ValueFromPipeline = $true,
                   Mandatory = $true)]
        [System.Reflection.TypeInfo]
        $TypeInfo
    )
    process
    {
        $TypeInfo | 
            Get-MemberProperty |
            ? { $_.Name -notin $Exclude } |
            ? { $_ | Test-DscProperty } |
            % { $TypeInfo | Assert-PropertyDefault $_.Name $null }
    }
}